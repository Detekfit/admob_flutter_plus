import 'package:flutter/widgets.dart';

import '../sdk/core/ad_request.dart';
import '../sdk/native/native_ad.dart';
import '../sdk/native/native_ad_listener.dart';
import '../sdk/native/native_ad_options.dart';
import '../sdk/native/native_ad_view_style.dart';
import '../sdk/native/native_ad_widgets.dart';
import 'ad_manager.dart';

/// Built-in native template layouts for [AdNative].
enum NativeTemplate {
  /// Compact: icon + headline + CTA (~92 dp).
  banner,

  /// Small: icon + headline + body + CTA (~150 dp).
  small,

  /// Large: media + headline + body + CTA (~380 dp).
  large,
}

/// Native ad placement used by [AdManager.native].
///
/// Loads a [NativeAd] and renders a built-in template or a custom asset XML.
/// Renders [placeholder] (or an empty box) when ads are disabled or load fails.
class AdNative extends StatefulWidget {
  /// Creates an [AdNative].
  const AdNative({
    super.key,
    required this.adUnitId,
    this.template = NativeTemplate.small,
    this.templateAsset,
    this.height,
    this.request = const AdRequest(),
    this.options = const NativeAdOptions(),
    this.style = const NativeAdViewStyle(),
    this.listener,
    this.placeholder,
  });

  /// AdMob ad unit ID.
  final String adUnitId;

  /// Built-in template. Ignored when [templateAsset] is set.
  final NativeTemplate template;

  /// Flutter-asset Android XML path for [NativeCustomAdView].
  final String? templateAsset;

  /// Reserved height. Defaults depend on [template] / custom asset.
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
    if (widget.templateAsset != null) return 360;
    switch (widget.template) {
      case NativeTemplate.banner:
        return 92;
      case NativeTemplate.small:
        return 150;
      case NativeTemplate.large:
        return 380;
    }
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
        oldWidget.template != widget.template ||
        oldWidget.templateAsset != widget.templateAsset) {
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
    final asset = widget.templateAsset;
    if (asset != null) {
      return NativeCustomAdView(
        ad: ad,
        templateAsset: asset,
        height: _resolvedHeight,
        style: widget.style,
        placeholder: widget.placeholder,
      );
    }

    switch (widget.template) {
      case NativeTemplate.banner:
        return NativeBannerAdView(
          ad: ad,
          height: _resolvedHeight,
          style: widget.style,
          placeholder: widget.placeholder,
        );
      case NativeTemplate.small:
        return NativeSmallAdView(
          ad: ad,
          height: _resolvedHeight,
          style: widget.style,
          placeholder: widget.placeholder,
        );
      case NativeTemplate.large:
        return NativeLargeAdView(
          ad: ad,
          height: _resolvedHeight,
          style: widget.style,
          placeholder: widget.placeholder,
        );
    }
  }
}
