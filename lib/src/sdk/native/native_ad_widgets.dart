import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'native_ad.dart';
import 'native_ad_view_style.dart';
import 'native_template_exception.dart';

/// Native template view types registered by the plugin.
const String _bannerViewType = 'admob_flutter_plus/native_banner';
const String _smallViewType = 'admob_flutter_plus/native_small';
const String _largeViewType = 'admob_flutter_plus/native_large';
const String _customViewType = 'admob_flutter_plus/native_custom';

/// Shared PlatformView wrapper for native ad templates.
class _NativeTemplateView extends StatelessWidget {
  const _NativeTemplateView({
    required this.viewType,
    required this.ad,
    required this.height,
    this.style = const NativeAdViewStyle(),
    this.placeholder,
    this.creationParams = const <String, dynamic>{},
  });

  final String viewType;
  final NativeAd ad;
  final double height;
  final NativeAdViewStyle style;
  final Widget? placeholder;
  final Map<String, dynamic> creationParams;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android || !ad.isLoaded) {
      return SizedBox(height: height, child: placeholder);
    }
    final resolvedStyle = style.resolve(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AndroidView(
        viewType: viewType,
        creationParams: <String, dynamic>{
          'adId': ad.adId,
          'style': resolvedStyle.toMap(),
          ...creationParams,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}

/// Compact native template: icon + headline + call-to-action (~92 dp).
class NativeBannerAdView extends StatelessWidget {
  /// Creates a [NativeBannerAdView] bound to a loaded [ad].
  const NativeBannerAdView({
    super.key,
    required this.ad,
    this.height = 92,
    this.style = const NativeAdViewStyle(),
    this.placeholder,
  });

  /// The loaded [NativeAd] to render.
  final NativeAd ad;

  /// Reserved height in dp.
  final double height;

  /// Template styling.
  final NativeAdViewStyle style;

  /// Widget shown before the ad is loaded or on unsupported platforms.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) => _NativeTemplateView(
        viewType: _bannerViewType,
        ad: ad,
        height: height,
        style: style,
        placeholder: placeholder,
      );
}

/// Small native template: icon + headline + body + call-to-action (~150 dp).
class NativeSmallAdView extends StatelessWidget {
  /// Creates a [NativeSmallAdView] bound to a loaded [ad].
  const NativeSmallAdView({
    super.key,
    required this.ad,
    this.height = 150,
    this.style = const NativeAdViewStyle(),
    this.placeholder,
  });

  /// The loaded [NativeAd] to render.
  final NativeAd ad;

  /// Reserved height in dp.
  final double height;

  /// Template styling.
  final NativeAdViewStyle style;

  /// Widget shown before the ad is loaded or on unsupported platforms.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) => _NativeTemplateView(
        viewType: _smallViewType,
        ad: ad,
        height: height,
        style: style,
        placeholder: placeholder,
      );
}

/// Large native template: media + headline + body + call-to-action (~380 dp).
class NativeLargeAdView extends StatelessWidget {
  /// Creates a [NativeLargeAdView] bound to a loaded [ad].
  const NativeLargeAdView({
    super.key,
    required this.ad,
    this.height = 380,
    this.style = const NativeAdViewStyle(),
    this.placeholder,
  });

  /// The loaded [NativeAd] to render.
  final NativeAd ad;

  /// Reserved height in dp.
  final double height;

  /// Template styling.
  final NativeAdViewStyle style;

  /// Widget shown before the ad is loaded or on unsupported platforms.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) => _NativeTemplateView(
        viewType: _largeViewType,
        ad: ad,
        height: height,
        style: style,
        placeholder: placeholder,
      );
}

/// Renders a loaded [NativeAd] using a custom Android XML layout from Flutter
/// assets.
///
/// Declare the file under `flutter/assets` in your app's `pubspec.yaml`.
/// Asset templates must bind widgets with `android:tag` (not `@+id`):
///
/// Required tags:
/// * `ad_view` — root [NativeAdView] (or use the NativeAdView class as root)
/// * `ad_headline` — headline [TextView]
/// * `ad_call_to_action` — CTA [Button] or [TextView]
///
/// Optional tags: `ad_body`, `ad_app_icon`, `ad_attribution`, `ad_media`,
/// `ad_advertiser`, `ad_price`, `ad_store`, `ad_stars`.
///
/// Throws [NativeTemplateException] if the asset cannot be loaded. Native-side
/// inflation / missing required tags also raise [NativeTemplateException].
///
/// Avoid `@drawable/...` and theme attrs in asset XML; use literal colors and
/// fully-qualified view class names (`NativeAdView`, `MediaView`).
class NativeCustomAdView extends StatefulWidget {
  /// Creates a [NativeCustomAdView] bound to a loaded [ad] and [templateAsset].
  const NativeCustomAdView({
    super.key,
    required this.ad,
    required this.templateAsset,
    this.package,
    this.height = 200,
    this.style = const NativeAdViewStyle(),
    this.placeholder,
  });

  /// The loaded [NativeAd] to render.
  final NativeAd ad;

  /// Flutter asset path to the Android XML template
  /// (for example `assets/native/my_template.xml`).
  final String templateAsset;

  /// Optional package name when the asset lives in another package.
  final String? package;

  /// Reserved height in dp for the Flutter [SizedBox] host.
  final double height;

  /// Template styling overlays (colors, CTA radius, badge text, …).
  final NativeAdViewStyle style;

  /// Widget shown before the ad is loaded, while validating the asset, or on
  /// unsupported platforms.
  final Widget? placeholder;

  @override
  State<NativeCustomAdView> createState() => _NativeCustomAdViewState();
}

class _NativeCustomAdViewState extends State<NativeCustomAdView> {
  Object? _error;
  String? _templateXml;

  @override
  void initState() {
    super.initState();
    _validateAsset();
  }

  @override
  void didUpdateWidget(covariant NativeCustomAdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateAsset != widget.templateAsset ||
        oldWidget.package != widget.package) {
      _validateAsset();
    }
  }

  Future<void> _validateAsset() async {
    setState(() {
      _error = null;
      _templateXml = null;
    });
    final key = widget.package == null
        ? widget.templateAsset
        : 'packages/${widget.package}/${widget.templateAsset}';
    try {
      final xml = await rootBundle.loadString(key);
      if (!mounted) return;
      setState(() => _templateXml = xml);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = NativeTemplateException(
          'Native ad template not found. Declare it under flutter/assets '
          'in pubspec.yaml.',
          assetPath: widget.templateAsset,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      // Surface loudly so missing templates are never silently ignored.
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    final xml = _templateXml;
    if (xml == null) {
      return SizedBox(height: widget.height, child: widget.placeholder);
    }
    return _NativeTemplateView(
      viewType: _customViewType,
      ad: widget.ad,
      height: widget.height,
      style: widget.style,
      placeholder: widget.placeholder,
      creationParams: <String, dynamic>{
        'templateAsset': widget.templateAsset,
        'templateXml': xml,
        if (widget.package != null) 'templatePackage': widget.package,
      },
    );
  }
}
