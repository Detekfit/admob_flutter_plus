import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'native_ad.dart';
import 'native_ad_view_style.dart';

/// Native template view types registered by the plugin.
const String _bannerViewType = 'admob_flutter_plus/native_banner';
const String _smallViewType = 'admob_flutter_plus/native_small';
const String _largeViewType = 'admob_flutter_plus/native_large';

/// Shared PlatformView wrapper for native ad templates.
class _NativeTemplateView extends StatelessWidget {
  const _NativeTemplateView({
    required this.viewType,
    required this.ad,
    required this.height,
    this.style = const NativeAdViewStyle(),
    this.placeholder,
  });

  final String viewType;
  final NativeAd ad;
  final double height;
  final NativeAdViewStyle style;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android || !ad.isLoaded) {
      return SizedBox(height: height, child: placeholder);
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AndroidView(
        viewType: viewType,
        creationParams: <String, dynamic>{
          'adId': ad.adId,
          'style': style.toMap(),
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
