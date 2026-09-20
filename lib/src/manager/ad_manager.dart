import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../sdk/app_open/app_open_ad.dart';
import '../sdk/banner/ad_size.dart';
import '../sdk/banner/banner_ad_controller.dart';
import '../sdk/banner/banner_ad_listener.dart';
import '../sdk/consent/consent.dart';
import '../sdk/core/ad_request.dart';
import '../sdk/core/app_state_event_notifier.dart';
import '../sdk/core/full_screen_ad.dart';
import '../sdk/core/initialization_status.dart';
import '../sdk/core/mobile_ads.dart';
import '../sdk/core/request_configuration.dart';
import '../sdk/interstitial/interstitial_ad.dart';
import '../sdk/native/native_ad_listener.dart';
import '../sdk/native/native_ad_options.dart';
import '../sdk/native/native_ad_view_style.dart';
import '../sdk/pip/picture_in_picture_ad.dart';
import '../sdk/pip/picture_in_picture_ad_listener.dart';
import '../sdk/pip/picture_in_picture_ad_options.dart';
import '../sdk/preload/banner_ad_preloader.dart';
import '../sdk/preload/interstitial_ad_preloader.dart';
import '../sdk/preload/rewarded_ad_preloader.dart';
import '../sdk/preload/rewarded_interstitial_ad_preloader.dart';
import '../sdk/rewarded/reward_item.dart';
import '../sdk/rewarded/rewarded_ad.dart';
import '../sdk/rewarded/rewarded_interstitial/rewarded_interstitial_ad.dart';
import 'ad_banner.dart';
import 'ad_native.dart';

/// Ad unit IDs used **only** by AdManager preloaders / resume app-open.
///
/// On-demand methods (`interstitial`, `reward`, `banner`, …) always take their
/// own required [adUnitId] and never fall back to these values.
@immutable
class PreAdUnitIds {
  /// Creates [PreAdUnitIds].
  const PreAdUnitIds({
    this.interstitial,
    this.rewarded,
    this.rewardedInterstitial,
    this.banner,
    this.appOpen,
  });

  /// Preloaded interstitial unit.
  final String? interstitial;

  /// Preloaded rewarded unit.
  final String? rewarded;

  /// Preloaded rewarded interstitial unit.
  final String? rewardedInterstitial;

  /// Unit for [AdManager.showPreLoadedBanner].
  final String? banner;

  /// Unit for resume app-open when [AdManager.initialize] sets
  /// `showAppOpenOnResume: true`.
  final String? appOpen;
}

/// Convenience facade over the low-level AdMob SDK APIs.
///
/// Call [initialize] from `main` before `runApp`. Prefer this helper for
/// common flows; use the sdk types directly for full control.
class AdManager {
  AdManager._();

  static final ValueNotifier<bool> _adsEnabled = ValueNotifier<bool>(true);

  static bool _initialized = false;
  static PreAdUnitIds _preAdUnitIds = const PreAdUnitIds();
  static bool _preloadInterstitial = false;
  static bool _preloadRewarded = false;
  static bool _preloadRewardedInterstitial = false;
  static bool _preloadBanner = false;
  static AdSize _preloadBannerSize = const AdSize.anchored();
  static bool _showAppOpenOnResume = false;
  static int _bufferSize = 2;

  static bool _fullscreenBusy = false;
  static bool _sawBackground = false;
  static StreamSubscription<AppState>? _appStateSub;
  static AppOpenAd? _resumeAppOpen;
  static PictureInPictureAd? _popAd;

  /// Whether ads are globally enabled (load + impression).
  static bool get adsEnabled => _adsEnabled.value;

  /// Listen for [adsEnabled] changes (used by manager widgets).
  static ValueListenable<bool> get adsEnabledListenable => _adsEnabled;

  /// Whether [initialize] has completed (successfully or with caught errors).
  static bool get isInitialized => _initialized;

  /// Ad units configured for preload / resume at [initialize].
  static PreAdUnitIds get preAdUnitIds => _preAdUnitIds;

  /// Initializes consent, the Mobile Ads SDK, optional preloaders, and optional
  /// resume app-open listening.
  ///
  /// **Never throws.** Failures are reported in debug only so `runApp()` is
  /// always reachable.
  static Future<InitializationStatus?> initialize({
    bool adsEnabled = true,
    List<String>? testDeviceIds,
    bool preloadInterstitial = false,
    bool preloadRewarded = false,
    bool preloadRewardedInterstitial = false,
    bool preloadBanner = false,
    AdSize preloadBannerSize = const AdSize.anchored(),
    bool showAppOpenOnResume = false,
    PreAdUnitIds preAdUnitIds = const PreAdUnitIds(),
    int bufferSize = 2,
  }) async {
    if (_initialized) {
      return MobileAds.instance.lastInitializationStatus;
    }

    _adsEnabled.value = adsEnabled;
    _preAdUnitIds = preAdUnitIds;
    _preloadInterstitial = preloadInterstitial;
    _preloadRewarded = preloadRewarded;
    _preloadRewardedInterstitial = preloadRewardedInterstitial;
    _preloadBanner = preloadBanner;
    _preloadBannerSize = preloadBannerSize;
    _showAppOpenOnResume = showAppOpenOnResume;
    _bufferSize = bufferSize.clamp(1, 15);

    InitializationStatus? status;

    try {
      _debugCheckPreloadUnits();

      try {
        await ConsentInformation.instance.requestConsentInfoUpdate(
          ConsentRequestParameters(
            testDeviceHashedIds: testDeviceIds ?? const <String>[],
          ),
        );
        await ConsentForm.loadAndShowConsentFormIfRequired();
      } catch (error, stack) {
        _reportDebug('Consent failed (continuing): $error', stack);
      }

      var canRequest = true;
      try {
        canRequest = await ConsentInformation.instance.canRequestAds();
      } catch (_) {
        canRequest = true;
      }

      if (canRequest) {
        status = await MobileAds.instance.initialize();
      } else {
        // Still initialize so ads can load where the SDK allows.
        try {
          status = await MobileAds.instance.initialize();
        } catch (error, stack) {
          _reportDebug('MobileAds.initialize failed: $error', stack);
        }
      }

      if (testDeviceIds != null && testDeviceIds.isNotEmpty) {
        await MobileAds.instance.setRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDeviceIds),
        );
      }

      if (_adsEnabled.value) {
        await _startPreloaders();
        if (_showAppOpenOnResume) {
          await _startResumeAppOpen();
        }
      }
    } catch (error, stack) {
      _reportDebug('AdManager.initialize error: $error', stack);
    }

    _initialized = true;
    return status;
  }

  /// Enables or disables all AdManager ad requests and impressions at runtime.
  ///
  /// Use after a subscription purchase, for example.
  static Future<void> setAdsEnabled(bool enabled) async {
    if (_adsEnabled.value == enabled) return;
    _adsEnabled.value = enabled;
    if (!enabled) {
      await _stopPreloaders();
      await _disposeResumeAppOpen();
      await _stopResumeListener();
      await hidePopAd();
      await _disposePopAd();
      return;
    }
    if (!_initialized) return;
    await _startPreloaders();
    if (_showAppOpenOnResume) {
      await _startResumeAppOpen();
    }
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  /// On-demand banner. [adUnitId] is required.
  static Widget banner({
    Key? key,
    required String adUnitId,
    required AdSize size,
    double? height,
    AdRequest request = const AdRequest(),
    BannerAdListener? listener,
    BannerAdController? controller,
    Widget? placeholder,
  }) {
    return AdBanner(
      key: key,
      adUnitId: adUnitId,
      size: size,
      height: height,
      request: request,
      listener: listener,
      controller: controller,
      placeholder: placeholder,
    );
  }

  /// Banner using [PreAdUnitIds.banner] from [initialize]. No [adUnitId] arg.
  ///
  /// Polls the banner preload buffer started when `preloadBanner: true`.
  /// Prefer the same [size] as `preloadBannerSize` on [initialize]; when
  /// omitted, the stored preload size is used.
  static Widget showPreLoadedBanner({
    Key? key,
    AdSize? size,
    double? height,
    AdRequest request = const AdRequest(),
    BannerAdListener? listener,
    BannerAdController? controller,
    Widget? placeholder,
  }) {
    final id = _preAdUnitIds.banner;
    if (id == null || id.isEmpty) {
      _reportDebug(
        'showPreLoadedBanner: preAdUnitIds.banner is missing '
        '(preloadBanner=$_preloadBanner).',
      );
      return placeholder ?? const SizedBox.shrink();
    }
    return AdBanner(
      key: key,
      adUnitId: id,
      size: size ?? _preloadBannerSize,
      height: height,
      request: request,
      listener: listener,
      controller: controller,
      placeholder: placeholder,
      usePreload: true,
    );
  }

  /// On-demand native ad. [adUnitId] and [template] are required.
  static Widget native({
    Key? key,
    required String adUnitId,
    required NativeTemplate template,
    double? height,
    AdRequest request = const AdRequest(),
    NativeAdOptions options = const NativeAdOptions(),
    NativeAdViewStyle style = const NativeAdViewStyle(),
    NativeAdListener? listener,
    Widget? placeholder,
  }) {
    return AdNative(
      key: key,
      adUnitId: adUnitId,
      template: template,
      height: height,
      request: request,
      options: options,
      style: style,
      listener: listener,
      placeholder: placeholder,
    );
  }

  // ---------------------------------------------------------------------------
  // Load-and-show (no `show` prefix)
  // ---------------------------------------------------------------------------

  /// Load-and-show interstitial. Polls the preloader for [adUnitId] first.
  static Future<void> interstitial({
    required String adUnitId,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      InterstitialAd? ad =
          await InterstitialAdPreloader.poll(adUnitId: adUnitId);
      ad ??= await _loadInterstitial(adUnitId);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showInterstitial(
        ad,
        onClosed: onClosed,
        onImpression: onImpression,
        onClicked: onClicked,
        onUnavailable: onUnavailable,
      );
    } finally {
      _fullscreenBusy = false;
    }
  }

  /// Load-and-show rewarded. Polls the preloader for [adUnitId] first.
  static Future<void> reward({
    required String adUnitId,
    required void Function(RewardItem reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      RewardedAd? ad = await RewardedAdPreloader.poll(adUnitId: adUnitId);
      ad ??= await _loadRewarded(adUnitId);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewarded(
        ad,
        onReward: onReward,
        onClosed: onClosed,
        onImpression: onImpression,
        onClicked: onClicked,
        onUnavailable: onUnavailable,
      );
    } finally {
      _fullscreenBusy = false;
    }
  }

  /// Load-and-show rewarded interstitial. Polls preloader for [adUnitId] first.
  static Future<void> rewardInterstitial({
    required String adUnitId,
    required void Function(RewardItem reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      RewardedInterstitialAd? ad =
          await RewardedInterstitialAdPreloader.poll(adUnitId: adUnitId);
      ad ??= await _loadRewardedInterstitial(adUnitId);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewardedInterstitial(
        ad,
        onReward: onReward,
        onClosed: onClosed,
        onImpression: onImpression,
        onClicked: onClicked,
        onUnavailable: onUnavailable,
      );
    } finally {
      _fullscreenBusy = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Preloaded show* (prefer buffer; one load-and-show if not ready)
  // ---------------------------------------------------------------------------

  /// Shows a preloaded interstitial from [PreAdUnitIds.interstitial].
  ///
  /// Prefers the SDK buffer. If empty (not ready / still loading / no fill),
  /// performs **one** load-then-show — never loops.
  static Future<void> showPreLoadedInterstitial({
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final id = _preAdUnitIds.interstitial;
    if (id == null || id.isEmpty) {
      _reportDebug('showPreLoadedInterstitial: preAdUnitIds.interstitial missing');
      onUnavailable?.call();
      return;
    }
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      InterstitialAd? ad =
          await InterstitialAdPreloader.poll(adUnitId: id);
      ad ??= await _loadInterstitial(id);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showInterstitial(
        ad,
        onClosed: onClosed,
        onImpression: onImpression,
        onClicked: onClicked,
        onUnavailable: onUnavailable,
      );
    } finally {
      _fullscreenBusy = false;
    }
  }

  /// Shows a preloaded rewarded ad from [PreAdUnitIds.rewarded].
  ///
  /// Prefers the SDK buffer. If empty, performs **one** load-then-show.
  static Future<void> showPreLoadedReward({
    required void Function(RewardItem reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final id = _preAdUnitIds.rewarded;
    if (id == null || id.isEmpty) {
      _reportDebug('showPreLoadedReward: preAdUnitIds.rewarded missing');
      onUnavailable?.call();
      return;
    }
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      RewardedAd? ad = await RewardedAdPreloader.poll(adUnitId: id);
      ad ??= await _loadRewarded(id);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewarded(
        ad,
        onReward: onReward,
        onClosed: onClosed,
        onImpression: onImpression,
        onClicked: onClicked,
        onUnavailable: onUnavailable,
      );
    } finally {
      _fullscreenBusy = false;
    }
  }

  /// Shows a preloaded rewarded interstitial from
  /// [PreAdUnitIds.rewardedInterstitial].
  ///
  /// Prefers the SDK buffer. If empty, performs **one** load-then-show.
  static Future<void> showPreLoadedRewardInterstitial({
    required void Function(RewardItem reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final id = _preAdUnitIds.rewardedInterstitial;
    if (id == null || id.isEmpty) {
      _reportDebug(
        'showPreLoadedRewardInterstitial: '
        'preAdUnitIds.rewardedInterstitial missing',
      );
      onUnavailable?.call();
      return;
    }
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      RewardedInterstitialAd? ad =
          await RewardedInterstitialAdPreloader.poll(adUnitId: id);
      ad ??= await _loadRewardedInterstitial(id);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewardedInterstitial(
        ad,
        onReward: onReward,
        onClosed: onClosed,
        onImpression: onImpression,
        onClicked: onClicked,
        onUnavailable: onUnavailable,
      );
    } finally {
      _fullscreenBusy = false;
    }
  }

  // ---------------------------------------------------------------------------
  // App open (first-open only) + Pop (PiP)
  // ---------------------------------------------------------------------------

  /// First-open / custom app-open. Does **not** enable resume listening.
  ///
  /// Resume ads are controlled only by `showAppOpenOnResume` on [initialize].
  static Future<void> showAppOpen({
    required String adUnitId,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      final ad = await AppOpenAd.load(adUnitId: adUnitId);
      if (!await ad.isAvailable()) {
        await ad.dispose();
        onUnavailable?.call();
        return;
      }
      final completer = Completer<void>();
      var failed = false;
      ad.listener = FullScreenAdListener(
        onAdImpression: onImpression,
        onAdClicked: onClicked,
        onAdDismissedFullScreenContent: () {
          onClosed?.call();
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToShowFullScreenContent: (_) {
          failed = true;
          if (!completer.isCompleted) completer.complete();
        },
      );
      await ad.show();
      await completer.future;
      if (failed) onUnavailable?.call();
    } catch (_) {
      onUnavailable?.call();
    } finally {
      _fullscreenBusy = false;
    }
  }

  /// Loads and shows a picture-in-picture (pop) ad. [adUnitId] is required.
  static Future<void> showPopAd({
    required String adUnitId,
    PictureInPictureAdOptions options = const PictureInPictureAdOptions(),
    void Function()? onShown,
    void Function()? onHidden,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_adsEnabled.value) {
      onUnavailable?.call();
      return;
    }

    try {
      await _disposePopAd();
      final ad = await PictureInPictureAd.load(adUnitId: adUnitId);
      ad.listener = PictureInPictureAdListener(
        onAdShown: onShown,
        onAdHidden: onHidden,
        onAdImpression: onImpression,
        onAdClicked: onClicked,
        onAdFailedToShowFullScreenContent: (_) => onUnavailable?.call(),
      );
      _popAd = ad;
      await ad.show(options: options);
    } catch (_) {
      await _disposePopAd();
      onUnavailable?.call();
    }
  }

  /// Hides the managed pop ad without disposing it.
  static Future<void> hidePopAd() async {
    await _popAd?.hide();
  }

  /// Shows the UMP privacy options form (settings screen).
  static Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm();
    } catch (error, stack) {
      _reportDebug('showPrivacyOptions failed: $error', stack);
    }
  }

  // ---------------------------------------------------------------------------
  // Internals — preload / resume
  // ---------------------------------------------------------------------------

  static void _debugCheckPreloadUnits() {
    if (_preloadInterstitial &&
        (_preAdUnitIds.interstitial == null ||
            _preAdUnitIds.interstitial!.isEmpty)) {
      _reportDebug(
        'AdManager.initialize: preloadInterstitial is true but '
        'preAdUnitIds.interstitial is missing.',
      );
    }
    if (_preloadRewarded &&
        (_preAdUnitIds.rewarded == null || _preAdUnitIds.rewarded!.isEmpty)) {
      _reportDebug(
        'AdManager.initialize: preloadRewarded is true but '
        'preAdUnitIds.rewarded is missing.',
      );
    }
    if (_preloadRewardedInterstitial &&
        (_preAdUnitIds.rewardedInterstitial == null ||
            _preAdUnitIds.rewardedInterstitial!.isEmpty)) {
      _reportDebug(
        'AdManager.initialize: preloadRewardedInterstitial is true but '
        'preAdUnitIds.rewardedInterstitial is missing.',
      );
    }
    if (_preloadBanner &&
        (_preAdUnitIds.banner == null || _preAdUnitIds.banner!.isEmpty)) {
      _reportDebug(
        'AdManager.initialize: preloadBanner is true but '
        'preAdUnitIds.banner is missing.',
      );
    }
    if (_showAppOpenOnResume &&
        (_preAdUnitIds.appOpen == null || _preAdUnitIds.appOpen!.isEmpty)) {
      _reportDebug(
        'AdManager.initialize: showAppOpenOnResume is true but '
        'preAdUnitIds.appOpen is missing.',
      );
    }
  }

  static Future<void> _startPreloaders() async {
    final interstitial = _preAdUnitIds.interstitial;
    if (_preloadInterstitial && interstitial != null && interstitial.isNotEmpty) {
      try {
        await InterstitialAdPreloader.start(
          adUnitId: interstitial,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Interstitial preloader failed: $error', stack);
      }
    }

    final rewarded = _preAdUnitIds.rewarded;
    if (_preloadRewarded && rewarded != null && rewarded.isNotEmpty) {
      try {
        await RewardedAdPreloader.start(
          adUnitId: rewarded,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Rewarded preloader failed: $error', stack);
      }
    }

    final rewardedInterstitial = _preAdUnitIds.rewardedInterstitial;
    if (_preloadRewardedInterstitial &&
        rewardedInterstitial != null &&
        rewardedInterstitial.isNotEmpty) {
      try {
        await RewardedInterstitialAdPreloader.start(
          adUnitId: rewardedInterstitial,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Rewarded interstitial preloader failed: $error', stack);
      }
    }

    final banner = _preAdUnitIds.banner;
    if (_preloadBanner && banner != null && banner.isNotEmpty) {
      try {
        await BannerAdPreloader.start(
          adUnitId: banner,
          size: _preloadBannerSize,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Banner preloader failed: $error', stack);
      }
    }
  }

  static Future<void> _stopPreloaders() async {
    final interstitial = _preAdUnitIds.interstitial;
    if (interstitial != null && interstitial.isNotEmpty) {
      try {
        await InterstitialAdPreloader.destroy(adUnitId: interstitial);
      } catch (_) {}
    }
    final rewarded = _preAdUnitIds.rewarded;
    if (rewarded != null && rewarded.isNotEmpty) {
      try {
        await RewardedAdPreloader.destroy(adUnitId: rewarded);
      } catch (_) {}
    }
    final rewardedInterstitial = _preAdUnitIds.rewardedInterstitial;
    if (rewardedInterstitial != null && rewardedInterstitial.isNotEmpty) {
      try {
        await RewardedInterstitialAdPreloader.destroy(
          adUnitId: rewardedInterstitial,
        );
      } catch (_) {}
    }
    final banner = _preAdUnitIds.banner;
    if (banner != null && banner.isNotEmpty) {
      try {
        await BannerAdPreloader.destroy(adUnitId: banner);
      } catch (_) {}
    }
  }

  static Future<void> _startResumeAppOpen() async {
    final id = _preAdUnitIds.appOpen;
    if (id == null || id.isEmpty) return;

    _sawBackground = false;
    await _loadResumeAppOpen();

    await AppStateEventNotifier.startListening();
    await _appStateSub?.cancel();
    _appStateSub = AppStateEventNotifier.appStateStream.listen((state) async {
      if (state == AppState.background) {
        _sawBackground = true;
        return;
      }
      if (state != AppState.foreground) return;
      if (!_sawBackground) return;
      if (!_adsEnabled.value || _fullscreenBusy) return;

      _fullscreenBusy = true;
      try {
        var ad = _resumeAppOpen;
        if (ad == null || !await ad.isAvailable()) {
          await _disposeResumeAppOpen();
          await _loadResumeAppOpen();
          ad = _resumeAppOpen;
        }
        if (ad == null || !await ad.isAvailable()) return;

        final completer = Completer<void>();
        ad.listener = FullScreenAdListener(
          onAdDismissedFullScreenContent: () {
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToShowFullScreenContent: (_) {
            if (!completer.isCompleted) completer.complete();
          },
        );
        _resumeAppOpen = null;
        await ad.show();
        await completer.future;
        await _loadResumeAppOpen();
      } catch (error, stack) {
        _reportDebug('Resume app open failed: $error', stack);
      } finally {
        _fullscreenBusy = false;
      }
    });
  }

  static Future<void> _loadResumeAppOpen() async {
    final id = _preAdUnitIds.appOpen;
    if (id == null || id.isEmpty || !_adsEnabled.value) return;
    try {
      await _disposeResumeAppOpen();
      _resumeAppOpen = await AppOpenAd.load(adUnitId: id);
    } catch (error, stack) {
      _reportDebug('Failed to cache resume app open: $error', stack);
      _resumeAppOpen = null;
    }
  }

  static Future<void> _disposeResumeAppOpen() async {
    final ad = _resumeAppOpen;
    _resumeAppOpen = null;
    try {
      await ad?.dispose();
    } catch (_) {}
  }

  static Future<void> _stopResumeListener() async {
    final hadListener = _appStateSub != null;
    await _appStateSub?.cancel();
    _appStateSub = null;
    if (!hadListener) return;
    try {
      await AppStateEventNotifier.stopListening();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Internals — show helpers
  // ---------------------------------------------------------------------------

  static bool _canShowFullscreen(void Function()? onUnavailable) {
    if (!_adsEnabled.value || _fullscreenBusy) {
      onUnavailable?.call();
      return false;
    }
    return true;
  }

  static Future<InterstitialAd?> _loadInterstitial(String adUnitId) async {
    try {
      return await InterstitialAd.load(adUnitId: adUnitId);
    } catch (_) {
      return null;
    }
  }

  static Future<RewardedAd?> _loadRewarded(String adUnitId) async {
    try {
      return await RewardedAd.load(adUnitId: adUnitId);
    } catch (_) {
      return null;
    }
  }

  static Future<RewardedInterstitialAd?> _loadRewardedInterstitial(
    String adUnitId,
  ) async {
    try {
      return await RewardedInterstitialAd.load(adUnitId: adUnitId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _showInterstitial(
    InterstitialAd ad, {
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final completer = Completer<void>();
    var failed = false;
    ad.listener = FullScreenAdListener(
      onAdImpression: onImpression,
      onAdClicked: onClicked,
      onAdDismissedFullScreenContent: () {
        onClosed?.call();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (_) {
        failed = true;
        if (!completer.isCompleted) completer.complete();
      },
    );
    try {
      await ad.show();
      await completer.future;
      if (failed) onUnavailable?.call();
    } catch (_) {
      onUnavailable?.call();
    }
  }

  static Future<void> _showRewarded(
    RewardedAd ad, {
    required void Function(RewardItem reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final completer = Completer<void>();
    var failed = false;
    ad.listener = FullScreenAdListener(
      onAdImpression: onImpression,
      onAdClicked: onClicked,
      onAdDismissedFullScreenContent: () {
        onClosed?.call();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (_) {
        failed = true;
        if (!completer.isCompleted) completer.complete();
      },
    );
    try {
      await ad.show(onUserEarnedReward: onReward);
      await completer.future;
      if (failed) onUnavailable?.call();
    } catch (_) {
      onUnavailable?.call();
    }
  }

  static Future<void> _showRewardedInterstitial(
    RewardedInterstitialAd ad, {
    required void Function(RewardItem reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final completer = Completer<void>();
    var failed = false;
    ad.listener = FullScreenAdListener(
      onAdImpression: onImpression,
      onAdClicked: onClicked,
      onAdDismissedFullScreenContent: () {
        onClosed?.call();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (_) {
        failed = true;
        if (!completer.isCompleted) completer.complete();
      },
    );
    try {
      await ad.show(onUserEarnedReward: onReward);
      await completer.future;
      if (failed) onUnavailable?.call();
    } catch (_) {
      onUnavailable?.call();
    }
  }

  static Future<void> _disposePopAd() async {
    final ad = _popAd;
    _popAd = null;
    try {
      await ad?.dispose();
    } catch (_) {}
  }

  static void _reportDebug(String message, [StackTrace? stack]) {
    if (!kDebugMode) return;
    debugPrint('admob_flutter_plus: $message');
    if (stack != null) {
      debugPrint('$stack');
    }
  }

  /// Test-only: reset static state between unit tests.
  @visibleForTesting
  static void debugReset() {
    _initialized = false;
    _adsEnabled.value = true;
    _preAdUnitIds = const PreAdUnitIds();
    _preloadInterstitial = false;
    _preloadRewarded = false;
    _preloadRewardedInterstitial = false;
    _preloadBanner = false;
    _preloadBannerSize = const AdSize.anchored();
    _showAppOpenOnResume = false;
    _bufferSize = 2;
    _fullscreenBusy = false;
    _sawBackground = false;
    _appStateSub = null;
    _resumeAppOpen = null;
    _popAd = null;
  }

  /// Test-only: seed [preAdUnitIds] without calling [initialize].
  @visibleForTesting
  static void debugSetPreAdUnitIds(PreAdUnitIds ids) {
    _preAdUnitIds = ids;
  }

  /// Test-only: seed `preloadBannerSize` without calling [initialize].
  @visibleForTesting
  static void debugSetPreloadBannerSize(AdSize size) {
    _preloadBannerSize = size;
  }

  /// Test-only: whether the resume latch has seen a background event.
  @visibleForTesting
  static bool get debugSawBackground => _sawBackground;

  /// Test-only: mark that a background event occurred (resume latch).
  @visibleForTesting
  static void debugSetSawBackground(bool value) {
    _sawBackground = value;
  }
}
