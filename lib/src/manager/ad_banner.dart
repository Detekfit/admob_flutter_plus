import 'package:flutter/widgets.dart';

import '../sdk/banner/ad_size.dart';
import '../sdk/banner/banner_ad_controller.dart';
import '../sdk/banner/banner_ad_listener.dart';
import '../sdk/banner/banner_ad_view.dart';
import '../sdk/core/ad_request.dart';
import 'ad_manager.dart';

/// Banner placement used by [AdManager.banner] and [AdManager.showPreLoadedBanner].
///
/// Renders nothing when [AdManager.adsEnabled] is `false`.
class AdBanner extends StatelessWidget {
  /// Creates an [AdBanner].
  const AdBanner({
    super.key,
    required this.adUnitId,
    required this.size,
    this.height,
    this.request = const AdRequest(),
    this.listener,
    this.controller,
    this.placeholder,
  });

  /// AdMob ad unit ID.
  final String adUnitId;

  /// Requested banner size.
  final AdSize size;

  /// Reserved height in dp.
  final double? height;

  /// Per-request targeting.
  final AdRequest request;

  /// Optional lifecycle callbacks.
  final BannerAdListener? listener;

  /// Optional refresh controller.
  final BannerAdController? controller;

  /// Shown when ads are disabled or the platform is unsupported.
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AdManager.adsEnabledListenable,
      builder: (context, enabled, _) {
        if (!enabled) {
          return placeholder ?? const SizedBox.shrink();
        }
        return BannerAdView(
          adUnitId: adUnitId,
          size: size,
          height: height,
          request: request,
          listener: listener,
          controller: controller,
          placeholder: placeholder,
        );
      },
    );
  }
}
