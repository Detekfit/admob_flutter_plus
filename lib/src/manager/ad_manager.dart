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
import '../sdk/core/rewarded_full_screen_ad.dart';
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

/// One ad unit to preload, or one resume app-open cache.
///
/// Pass a list to [AdManager.initialize]. A listed entry starts that preload.
/// On-demand methods (`interstitial`, `reward`, `banner`, …) always take their
/// own required `adUnitId` and never fall back to these entries.
@immutable
sealed class Preload {
  const Preload(this.adUnitId);

  /// Ad unit for this entry.
  final String adUnitId;

  /// Preloaded interstitial.
  const factory Preload.interstitial(String adUnitId) = InterstitialPreload;

  /// Preloaded rewarded ad.
  const factory Preload.rewarded(String adUnitId) = RewardedPreload;

  /// Preloaded rewarded interstitial.
  const factory Preload.rewardedInterstitial(String adUnitId) =
      RewardedInterstitialPreload;

  /// Preloaded banner. Omit [size] to use [AdSize.anchored].
  const factory Preload.banner(String adUnitId, {AdSize? size}) = BannerPreload;

  /// One app-open ad cached for resume. Not an SDK preloader, and never shown
  /// on cold start.
  const factory Preload.appOpenOnResume(String adUnitId) = AppOpenResumePreload;
}

/// [Preload.interstitial].
final class InterstitialPreload extends Preload {
  /// Creates an interstitial preload entry.
  const InterstitialPreload(super.adUnitId);
}

/// [Preload.rewarded].
final class RewardedPreload extends Preload {
  /// Creates a rewarded preload entry.
  const RewardedPreload(super.adUnitId);
}

/// [Preload.rewardedInterstitial].
final class RewardedInterstitialPreload extends Preload {
  /// Creates a rewarded-interstitial preload entry.
  const RewardedInterstitialPreload(super.adUnitId);
}

/// [Preload.banner].
final class BannerPreload extends Preload {
  /// Creates a banner preload entry. A null [size] uses [AdSize.anchored].
  const BannerPreload(super.adUnitId, {AdSize? size})
    : size = size ?? const AdSize.anchored();

  /// Size requested for this banner buffer.
  final AdSize size;
}

/// [Preload.appOpenOnResume].
final class AppOpenResumePreload extends Preload {
  /// Creates a resume app-open entry.
  const AppOpenResumePreload(super.adUnitId);
}

/// Convenience facade over the low-level AdMob SDK APIs.
///
/// Call [initialize] from `main` before `runApp`. Prefer this helper for
/// common flows; use the sdk types directly for full control.
class AdManager {
  AdManager._();

  static final ValueNotifier<bool> _adsEnabled = ValueNotifier<bool>(true);

  static bool _initialized = false;
  static List<Preload> _preloads = const [];
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

  /// Entries configured for preload / resume at [initialize].
  static List<Preload> get preloads => List<Preload>.unmodifiable(_preloads);

  /// Initializes consent, the Mobile Ads SDK, optional preloaders, and optional
  /// resume app-open listening.
  ///
  /// Each [preload] entry is one buffer or the resume app-open cache. An empty
  /// list starts nothing. Preloaders and resume app-open start only when a live
  /// `canRequestAds()` read is true. [onConsentDismissed] runs when the consent
  /// form closes, or when no form was required, before those loads. `true`
  /// means that read allowed the loads. `false` means Google returned false, or
  /// the read itself failed.
  ///
  /// **Never throws.** Failures are reported in debug only so `runApp()` is
  /// always reachable.
  static Future<InitializationStatus?> initialize({
    bool adsEnabled = true,
    List<String>? testDeviceIds,
    List<Preload> preload = const [],
    int bufferSize = 2,
    void Function(bool canRequestAds)? onConsentDismissed,
  }) async {
    if (_initialized) {
      return MobileAds.instance.lastInitializationStatus;
    }

    _adsEnabled.value = adsEnabled;
    _preloads = _foldPreloads(preload);
    _bufferSize = bufferSize.clamp(1, 15);

    InitializationStatus? status;

    try {
      try {
        await ConsentInformation.instance.requestConsentInfoUpdate(
          ConsentRequestParameters(
            testDeviceHashedIds: testDeviceIds ?? const <String>[],
          ),
        );
        await ConsentForm.loadAndShowConsentFormIfRequired();
      } catch (error, stack) {
        _reportDebug('Consent update failed: $error', stack);
      }
      final canRequest = await _readCanRequestAds();
      onConsentDismissed?.call(canRequest);

      try {
        status = await MobileAds.instance.initialize();
      } catch (error, stack) {
        _reportDebug('MobileAds.initialize failed: $error', stack);
      }

      if (testDeviceIds != null && testDeviceIds.isNotEmpty) {
        await MobileAds.instance.setRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDeviceIds),
        );
      }

      if (_mayStartPreloads(
        canRequestAds: canRequest,
        adsEnabled: _adsEnabled.value,
      )) {
        await _startPreloaders();
        if (_appOpenId != null) {
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
    final canRequest = await _readCanRequestAds();
    if (!_mayStartPreloads(canRequestAds: canRequest, adsEnabled: true)) {
      return;
    }
    await _startPreloaders();
    if (_appOpenId != null) {
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

  /// Banner using [Preload.banner] from [initialize]. No [adUnitId] arg.
  ///
  /// Polls the banner preload buffer for that entry. Prefer the same [size]
  /// as the entry; when omitted, the stored preload size is used.
  static Widget showPreLoadedBanner({
    Key? key,
    AdSize? size,
    double? height,
    AdRequest request = const AdRequest(),
    BannerAdListener? listener,
    BannerAdController? controller,
    Widget? placeholder,
  }) {
    final banner = _preload<BannerPreload>();
    if (banner == null) {
      _reportDebug('showPreLoadedBanner: Preload.banner is missing');
      return placeholder ?? const SizedBox.shrink();
    }
    return AdBanner(
      key: key,
      adUnitId: banner.adUnitId,
      size: size ?? banner.size,
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

  /// Load-and-show interstitial. Uses a preloaded ad for [adUnitId] when one
  /// is ready. Loads once only when that unit's preloader is not already
  /// requesting.
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
      InterstitialAd? ad = await InterstitialAdPreloader.poll(
        adUnitId: adUnitId,
      );
      if (ad == null && !_preloaderOwns(adUnitId, _interstitialId)) {
        ad = await _loadInterstitial(adUnitId);
      }
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

  /// Load-and-show rewarded. Uses a preloaded ad for [adUnitId] when one is
  /// ready. Loads once only when that unit's preloader is not already
  /// requesting.
  ///
  /// On dismiss, [onReward] runs first with `isReward == true` and the AdMob
  /// [RewardItem] when the user earned the reward, or `isReward == false` and
  /// `reward == null` when the ad was closed early. [onClosed] runs after that
  /// and is not a reward result.
  static Future<void> reward({
    required String adUnitId,
    required void Function(bool isReward, RewardItem? reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      RewardedAd? ad = await RewardedAdPreloader.poll(adUnitId: adUnitId);
      if (ad == null && !_preloaderOwns(adUnitId, _rewardedId)) {
        ad = await _loadRewarded(adUnitId);
      }
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewardedFullScreen(
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

  /// Load-and-show rewarded interstitial. Uses a preloaded ad for [adUnitId]
  /// when one is ready. Loads once only when that unit's preloader is not
  /// already requesting.
  ///
  /// On dismiss, [onReward] runs first with `isReward == true` and the AdMob
  /// [RewardItem] when the user earned the reward, or `isReward == false` and
  /// `reward == null` when the ad was closed early. [onClosed] runs after that
  /// and is not a reward result.
  static Future<void> rewardInterstitial({
    required String adUnitId,
    required void Function(bool isReward, RewardItem? reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      RewardedInterstitialAd? ad = await RewardedInterstitialAdPreloader.poll(
        adUnitId: adUnitId,
      );
      if (ad == null && !_preloaderOwns(adUnitId, _rewardedInterstitialId)) {
        ad = await _loadRewardedInterstitial(adUnitId);
      }
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewardedFullScreen(
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
  // Preloaded show* (buffer only — no second load)
  // ---------------------------------------------------------------------------

  /// Shows a preloaded interstitial from [Preload.interstitial].
  ///
  /// If the buffer is empty, calls [onUnavailable] and does not load.
  static Future<void> showPreLoadedInterstitial({
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final id = _interstitialId;
    if (id == null) {
      _reportDebug(
        'showPreLoadedInterstitial: Preload.interstitial is missing',
      );
      onUnavailable?.call();
      return;
    }
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      final InterstitialAd? ad = await InterstitialAdPreloader.poll(
        adUnitId: id,
      );
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

  /// Shows a preloaded rewarded ad from [Preload.rewarded].
  ///
  /// If the buffer is empty, calls [onUnavailable] and does not load.
  ///
  /// On dismiss, [onReward] runs first with `isReward == true` and the AdMob
  /// [RewardItem] when the user earned the reward, or `isReward == false` and
  /// `reward == null` when the ad was closed early. [onClosed] runs after that
  /// and is not a reward result.
  static Future<void> showPreLoadedReward({
    required void Function(bool isReward, RewardItem? reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final id = _rewardedId;
    if (id == null) {
      _reportDebug('showPreLoadedReward: Preload.rewarded is missing');
      onUnavailable?.call();
      return;
    }
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      final RewardedAd? ad = await RewardedAdPreloader.poll(adUnitId: id);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewardedFullScreen(
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
  /// [Preload.rewardedInterstitial].
  ///
  /// If the buffer is empty, calls [onUnavailable] and does not load.
  ///
  /// On dismiss, [onReward] runs first with `isReward == true` and the AdMob
  /// [RewardItem] when the user earned the reward, or `isReward == false` and
  /// `reward == null` when the ad was closed early. [onClosed] runs after that
  /// and is not a reward result.
  static Future<void> showPreLoadedRewardInterstitial({
    required void Function(bool isReward, RewardItem? reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final id = _rewardedInterstitialId;
    if (id == null) {
      _reportDebug(
        'showPreLoadedRewardInterstitial: Preload.rewardedInterstitial is missing',
      );
      onUnavailable?.call();
      return;
    }
    if (!_canShowFullscreen(onUnavailable)) return;

    _fullscreenBusy = true;
    try {
      final RewardedInterstitialAd? ad =
          await RewardedInterstitialAdPreloader.poll(adUnitId: id);
      if (ad == null) {
        onUnavailable?.call();
        return;
      }
      await _showRewardedFullScreen(
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
  /// Resume ads are controlled only by [Preload.appOpenOnResume] on [initialize].
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

  /// Keeps one entry per format. An empty id is dropped. A later duplicate
  /// replaces the earlier one.
  static List<Preload> _foldPreloads(List<Preload> preload) {
    final folded = <Type, Preload>{};
    for (final entry in preload) {
      if (entry.adUnitId.isEmpty) {
        _reportDebug(
          'AdManager.initialize: skipping ${entry.runtimeType} with an empty ad unit id.',
        );
        continue;
      }
      final previous = folded[entry.runtimeType];
      if (previous != null) {
        _reportDebug(
          'AdManager.initialize: replacing ${entry.runtimeType} '
          '${previous.adUnitId} with ${entry.adUnitId}.',
        );
      }
      folded[entry.runtimeType] = entry;
    }
    return folded.values.toList();
  }

  static T? _preload<T extends Preload>() {
    for (final entry in _preloads) {
      if (entry is T) return entry;
    }
    return null;
  }

  static String? get _interstitialId =>
      _preload<InterstitialPreload>()?.adUnitId;

  static String? get _rewardedId => _preload<RewardedPreload>()?.adUnitId;

  static String? get _rewardedInterstitialId =>
      _preload<RewardedInterstitialPreload>()?.adUnitId;

  static String? get _appOpenId => _preload<AppOpenResumePreload>()?.adUnitId;

  static Future<bool> _readCanRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (error, stack) {
      _reportDebug('canRequestAds failed: $error', stack);
      return false;
    }
  }

  static Future<void> _startPreloaders() async {
    final interstitial = _interstitialId;
    if (interstitial != null) {
      try {
        await InterstitialAdPreloader.start(
          adUnitId: interstitial,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Interstitial preloader failed: $error', stack);
      }
    }

    final rewarded = _rewardedId;
    if (rewarded != null) {
      try {
        await RewardedAdPreloader.start(
          adUnitId: rewarded,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Rewarded preloader failed: $error', stack);
      }
    }

    final rewardedInterstitial = _rewardedInterstitialId;
    if (rewardedInterstitial != null) {
      try {
        await RewardedInterstitialAdPreloader.start(
          adUnitId: rewardedInterstitial,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Rewarded interstitial preloader failed: $error', stack);
      }
    }

    final banner = _preload<BannerPreload>();
    if (banner != null) {
      try {
        await BannerAdPreloader.start(
          adUnitId: banner.adUnitId,
          size: banner.size,
          bufferSize: _bufferSize,
        );
      } catch (error, stack) {
        _reportDebug('Banner preloader failed: $error', stack);
      }
    }
  }

  static Future<void> _stopPreloaders() async {
    final interstitial = _interstitialId;
    if (interstitial != null) {
      try {
        await InterstitialAdPreloader.destroy(adUnitId: interstitial);
      } catch (_) {}
    }
    final rewarded = _rewardedId;
    if (rewarded != null) {
      try {
        await RewardedAdPreloader.destroy(adUnitId: rewarded);
      } catch (_) {}
    }
    final rewardedInterstitial = _rewardedInterstitialId;
    if (rewardedInterstitial != null) {
      try {
        await RewardedInterstitialAdPreloader.destroy(
          adUnitId: rewardedInterstitial,
        );
      } catch (_) {}
    }
    final banner = _preload<BannerPreload>();
    if (banner != null) {
      try {
        await BannerAdPreloader.destroy(adUnitId: banner.adUnitId);
      } catch (_) {}
    }
  }

  static Future<void> _startResumeAppOpen() async {
    final id = _appOpenId;
    if (id == null) return;

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
        final ad = _resumeAppOpen;
        if (ad == null) return;
        if (!await ad.isAvailable()) {
          await _disposeResumeAppOpen();
          await _loadResumeAppOpen();
          return;
        }

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
    final id = _appOpenId;
    if (id == null || !_adsEnabled.value) return;
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

  static bool _mayStartPreloads({
    required bool canRequestAds,
    required bool adsEnabled,
  }) => canRequestAds && adsEnabled;

  /// True when [preloadUnitId] is the unit already being preloaded, so an empty
  /// poll must not trigger another load.
  static bool _preloaderOwns(String adUnitId, String? preloadUnitId) =>
      preloadUnitId != null && preloadUnitId == adUnitId;

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

  /// Settles [onReward] at dismiss: store the AdMob item on earn, then on
  /// dismiss call [onReward] once (`true` + item, or `false` + null) and
  /// [onClosed] after that.
  static Future<void> _showRewardedFullScreen(
    RewardedFullScreenAd ad, {
    required void Function(bool isReward, RewardItem? reward) onReward,
    void Function()? onClosed,
    void Function()? onImpression,
    void Function()? onClicked,
    void Function()? onUnavailable,
  }) async {
    final completer = Completer<void>();
    var failed = false;
    var dismissed = false;
    var rewardReported = false;
    RewardItem? earned;

    ad.listener = FullScreenAdListener(
      onAdImpression: onImpression,
      onAdClicked: onClicked,
      onAdDismissedFullScreenContent: () {
        dismissed = true;
        if (!rewardReported) {
          rewardReported = true;
          onReward(earned != null, earned);
        }
        onClosed?.call();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (_) {
        failed = true;
        if (!completer.isCompleted) completer.complete();
      },
    );
    try {
      await ad.showRewarded(
        onUserEarnedReward: (reward) {
          if (dismissed || rewardReported) return;
          earned = reward;
        },
      );
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
    _preloads = const [];
    _bufferSize = 2;
    _fullscreenBusy = false;
    _sawBackground = false;
    _appStateSub = null;
    _resumeAppOpen = null;
    _popAd = null;
  }

  /// Test-only: whether an empty preload poll may issue one load.
  @visibleForTesting
  static bool debugPreloaderOwnsUnit({
    required String adUnitId,
    required String? preloadUnitId,
  }) => _preloaderOwns(adUnitId, preloadUnitId);

  /// Test-only: whether preloaders may start for this consent and ads flag.
  @visibleForTesting
  static bool debugMayStartPreloads({
    required bool canRequestAds,
    required bool adsEnabled,
  }) => _mayStartPreloads(canRequestAds: canRequestAds, adsEnabled: adsEnabled);

  /// Test-only: seed [preloads] without calling [initialize].
  @visibleForTesting
  static void debugSetPreloads(List<Preload> preload) {
    _preloads = _foldPreloads(preload);
  }

  /// Test-only: ad unit stored for [T], after folding.
  @visibleForTesting
  static String? debugPreloadAdUnitId<T extends Preload>() =>
      _preload<T>()?.adUnitId;

  /// Test-only: size stored for [Preload.banner].
  @visibleForTesting
  static AdSize? debugPreloadBannerSize() => _preload<BannerPreload>()?.size;

  /// Test-only: whether the resume latch has seen a background event.
  @visibleForTesting
  static bool get debugSawBackground => _sawBackground;

  /// Test-only: mark that a background event occurred (resume latch).
  @visibleForTesting
  static void debugSetSawBackground(bool value) {
    _sawBackground = value;
  }
}
