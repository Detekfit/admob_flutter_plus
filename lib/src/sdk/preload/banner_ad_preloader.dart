import '../banner/ad_size.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';

/// Preloads banner ads so they can be shown instantly.
///
/// Backed by the SDK's `BannerAdPreloader`. [start] requires an [AdSize]
/// because banner requests are size-specific. Display with
/// `BannerAdView(usePreload: true)` (the PlatformView polls natively).
class BannerAdPreloader {
  BannerAdPreloader._();

  static final AdsChannel _channel = AdsChannel.instance;

  /// Starts preloading banners for [adUnitId] at [size].
  ///
  /// [bufferSize] must be between 1 and 15 (the SDK default is 2).
  /// Use the same [size] when mounting `BannerAdView` with `usePreload: true`.
  static Future<void> start({
    required String adUnitId,
    required AdSize size,
    int bufferSize = 2,
    AdRequest request = const AdRequest(),
  }) async {
    await _channel.invoke<void>('startBannerPreload', {
      'adUnitId': adUnitId,
      'bufferSize': bufferSize,
      'size': size.toMap(),
      'request': request.toMap(),
    });
  }

  /// Whether at least one preloaded ad is available for [adUnitId].
  static Future<bool> isAvailable({required String adUnitId}) async {
    final value = await _channel.invoke<bool>('isBannerPreloadAvailable', {
      'adUnitId': adUnitId,
    });
    return value ?? false;
  }

  /// Number of preloaded ads currently buffered for [adUnitId].
  static Future<int> count({required String adUnitId}) async {
    final value = await _channel.invoke<int>('bannerPreloadCount', {
      'adUnitId': adUnitId,
    });
    return value ?? 0;
  }

  /// Stops preloading and releases buffered ads for [adUnitId].
  static Future<void> destroy({required String adUnitId}) async {
    await _channel.invoke<void>('destroyBannerPreload', {
      'adUnitId': adUnitId,
    });
  }
}
