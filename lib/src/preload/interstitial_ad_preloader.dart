import '../core/ad_request.dart';
import '../core/channel.dart';
import '../interstitial/interstitial_ad.dart';

/// Preloads interstitial ads so they can be shown instantly.
///
/// Backed by the SDK's `InterstitialAdPreloader`. Start a buffer for an ad
/// unit, [poll] to obtain a ready ad, and [destroy] when finished.
class InterstitialAdPreloader {
  InterstitialAdPreloader._();

  static final AdsChannel _channel = AdsChannel.instance;

  /// Starts preloading interstitials for [adUnitId].
  ///
  /// [bufferSize] controls how many ads are kept ready.
  static Future<void> start({
    required String adUnitId,
    int bufferSize = 2,
    AdRequest request = const AdRequest(),
  }) async {
    await _channel.invoke<void>('startInterstitialPreload', {
      'adUnitId': adUnitId,
      'bufferSize': bufferSize,
      'request': request.toMap(),
    });
  }

  /// Polls a ready ad for [adUnitId], or returns `null` if none is available.
  static Future<InterstitialAd?> poll({required String adUnitId}) async {
    final adId = _channel.nextAdId('interstitial_preload');
    final result = await _channel.invokeMap('pollInterstitialPreload', {
      'adUnitId': adUnitId,
      'adId': adId,
    });
    if (result['polled'] == true) {
      return InterstitialAd.internalAdopt(adId);
    }
    return null;
  }

  /// Whether at least one preloaded ad is available for [adUnitId].
  static Future<bool> isAvailable({required String adUnitId}) async {
    final value = await _channel.invoke<bool>('isInterstitialPreloadAvailable', {
      'adUnitId': adUnitId,
    });
    return value ?? false;
  }

  /// Number of preloaded ads currently buffered for [adUnitId].
  static Future<int> count({required String adUnitId}) async {
    final value = await _channel.invoke<int>('interstitialPreloadCount', {
      'adUnitId': adUnitId,
    });
    return value ?? 0;
  }

  /// Stops preloading and releases buffered ads for [adUnitId].
  static Future<void> destroy({required String adUnitId}) async {
    await _channel.invoke<void>('destroyInterstitialPreload', {
      'adUnitId': adUnitId,
    });
  }
}
