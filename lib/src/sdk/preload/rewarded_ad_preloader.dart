import '../core/ad_request.dart';
import '../core/channel.dart';
import '../rewarded/rewarded_ad.dart';

/// Preloads rewarded ads so they can be shown instantly.
///
/// Backed by the SDK's `RewardedAdPreloader`. The official Next-Gen docs
/// support preloading for rewarded ads (alongside interstitial and rewarded
/// interstitial). Mirrors [InterstitialAdPreloader].
class RewardedAdPreloader {
  RewardedAdPreloader._();

  static final AdsChannel _channel = AdsChannel.instance;

  /// Starts preloading rewarded ads for [adUnitId].
  ///
  /// [bufferSize] must be between 1 and 15 (the SDK default is 2).
  static Future<void> start({
    required String adUnitId,
    int bufferSize = 2,
    AdRequest request = const AdRequest(),
  }) async {
    await _channel.invoke<void>('startRewardedPreload', {
      'adUnitId': adUnitId,
      'bufferSize': bufferSize,
      'request': request.toMap(),
    });
  }

  /// Polls a ready ad for [adUnitId], or returns `null` if none is available.
  static Future<RewardedAd?> poll({required String adUnitId}) async {
    final adId = _channel.nextAdId('rewarded_preload');
    final result = await _channel.invokeMap('pollRewardedPreload', {
      'adUnitId': adUnitId,
      'adId': adId,
    });
    if (result['polled'] == true) {
      return RewardedAd.internalAdopt(
        adId,
        adUnitId: (result['adUnitId'] as String?) ?? adUnitId,
      );
    }
    return null;
  }

  /// Whether at least one preloaded ad is available for [adUnitId].
  static Future<bool> isAvailable({required String adUnitId}) async {
    final value = await _channel.invoke<bool>('isRewardedPreloadAvailable', {
      'adUnitId': adUnitId,
    });
    return value ?? false;
  }

  /// Number of preloaded ads currently buffered for [adUnitId].
  static Future<int> count({required String adUnitId}) async {
    final value = await _channel.invoke<int>('rewardedPreloadCount', {
      'adUnitId': adUnitId,
    });
    return value ?? 0;
  }

  /// Stops preloading and releases buffered ads for [adUnitId].
  static Future<void> destroy({required String adUnitId}) async {
    await _channel.invoke<void>('destroyRewardedPreload', {
      'adUnitId': adUnitId,
    });
  }
}
