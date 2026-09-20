import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../sdk/core/ad_request.dart';
import '../sdk/native/native_ad.dart';
import '../sdk/native/native_ad_listener.dart';
import '../sdk/native/native_ad_options.dart';
import '../sdk/native/native_ad_view_style.dart';
import '../sdk/native/native_ad_widgets.dart';
import 'ad_manager.dart';

/// Native template layout for [AdManager.native] / [AdNative].
///
/// Built-ins: [NativeTemplate.banner], [NativeTemplate.small],
/// [NativeTemplate.large]. Custom Flutter-asset XML:
/// `NativeTemplate.asset('assets/native/my_template.xml')`.
@immutable
class NativeTemplate {
  const NativeTemplate._(this._kind, [this.assetPath]);

  /// Compact: icon + headline + CTA (~92 dp).
  static const NativeTemplate banner = NativeTemplate._(_NativeTemplateKind.banner);

  /// Small: icon + headline + body + CTA (~150 dp).
  static const NativeTemplate small = NativeTemplate._(_NativeTemplateKind.small);

  /// Large: media + headline + body + CTA (~380 dp).
  static const NativeTemplate large = NativeTemplate._(_NativeTemplateKind.large);

  /// Custom Android XML from a Flutter asset path.
  const NativeTemplate.asset(String path)
      : this._(_NativeTemplateKind.asset, path);

  final _NativeTemplateKind _kind;

  /// Asset path when created with [NativeTemplate.asset]; otherwise `null`.
  final String? assetPath;

  /// Whether this template uses a custom asset XML.
  bool get isAsset => _kind == _NativeTemplateKind.asset;

  /// Short name for debugging (`banner`, `small`, `large`, or `asset`).
  String get name => _kind.name;

  @override
  bool operator ==(Object other) =>
      other is NativeTemplate &&
      other._kind == _kind &&
      other.assetPath == assetPath;

  @override
  int get hashCode => Object.hash(_kind, assetPath);

  @override
  String toString() =>
      isAsset ? 'NativeTemplate.asset($assetPath)' : 'NativeTemplate.$name';
}

enum _NativeTemplateKind { banner, small, large, asset }

/// Native ad placement used by [AdManager.native].
///
/// Loads a [NativeAd] and renders the chosen [template].
/// Renders [placeholder] (or an empty box) when ads are disabled or load fails.
class AdNative extends StatefulWidget {
  /// Creates an [AdNative].
  const AdNative({
    super.key,
    required this.adUnitId,
    required this.template,
    this.height,
    this.request = const AdRequest(),
    this.options = const NativeAdOptions(),
    this.style = const NativeAdViewStyle(),
    this.listener,
    this.placeholder,
  });

  /// AdMob ad unit ID.
  final String adUnitId;

  /// Built-in or custom asset template.
  final NativeTemplate template;

  /// Reserved height. Defaults depend on [template].
  final double? height;

  /// Per-request targeting.
  final AdRequest request;

  /// Native load options.
  final NativeAdOptions options;

  /// Template styling.
  final NativeAdViewStyle style;

  /// Lifecycle callbacks.
  final NativeAdListener? listener;

  /// Shown when ads are disabled or before/after a failed load.
  final Widget? placeholder;

  @override
  State<AdNative> createState() => _AdNativeState();
}

class _AdNativeState extends State<AdNative> {
  NativeAd? _ad;
  bool _failed = false;

  double get _resolvedHeight {
    if (widget.height != null) return widget.height!;
    final template = widget.template;
    if (template.isAsset) return 360;
    if (template == NativeTemplate.banner) return 92;
    if (template == NativeTemplate.large) return 380;
    return 150; // small (default built-in)
  }

  @override
  void initState() {
    super.initState();
    AdManager.adsEnabledListenable.addListener(_onAdsEnabledChanged);
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(AdNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.template != widget.template) {
      _disposeAd();
      _failed = false;
      _loadIfNeeded();
    }
  }

  @override
  void dispose() {
    AdManager.adsEnabledListenable.removeListener(_onAdsEnabledChanged);
    _disposeAd();
    super.dispose();
  }

  void _onAdsEnabledChanged() {
    if (!mounted) return;
    if (AdManager.adsEnabled) {
      _failed = false;
      _loadIfNeeded();
    } else {
      _disposeAd();
      setState(() {});
    }
  }

  Future<void> _loadIfNeeded() async {
    if (!AdManager.adsEnabled) return;
    if (_ad != null) return;
    final ad = NativeAd(
      adUnitId: widget.adUnitId,
      request: widget.request,
      options: widget.options,
      listener: widget.listener,
    );
    try {
      await ad.load();
      if (!mounted || !AdManager.adsEnabled) {
        await ad.dispose();
        return;
      }
      setState(() => _ad = ad);
    } catch (_) {
      await ad.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!AdManager.adsEnabled || _failed || _ad == null || !_ad!.isLoaded) {
      return SizedBox(
        height: _resolvedHeight,
        child: widget.placeholder,
      );
    }

    final ad = _ad!;
    final template = widget.template;
    final asset = template.assetPath;
    if (asset != null) {
      return NativeCustomAdView(
        ad: ad,
        templateAsset: asset,
        height: _resolvedHeight,
        style: widget.style,
        placeholder: widget.placeholder,
      );
    }

    if (template == NativeTemplate.banner) {
      return NativeBannerAdView(
        ad: ad,
        height: _resolvedHeight,
        style: widget.style,
        placeholder: widget.placeholder,
      );
    }
    if (template == NativeTemplate.large) {
      return NativeLargeAdView(
        ad: ad,
        height: _resolvedHeight,
        style: widget.style,
        placeholder: widget.placeholder,
      );
    }
    return NativeSmallAdView(
      ad: ad,
      height: _resolvedHeight,
      style: widget.style,
      placeholder: widget.placeholder,
    );
  }
}
