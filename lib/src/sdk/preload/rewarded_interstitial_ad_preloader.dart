import '../core/ad_request.dart';
import '../core/channel.dart';
import '../rewarded/rewarded_interstitial/rewarded_interstitial_ad.dart';

/// Preloads rewarded interstitial ads so they can be shown instantly.
///
/// Backed by the SDK's `RewardedInterstitialAdPreloader`. Mirrors
/// [InterstitialAdPreloader].
class RewardedInterstitialAdPreloader {
  RewardedInterstitialAdPreloader._();

  static final AdsChannel _channel = AdsChannel.instance;

  /// Starts preloading rewarded interstitials for [adUnitId].
  static Future<void> start({
    required String adUnitId,
    int bufferSize = 2,
    AdRequest request = const AdRequest(),
  }) async {
    await _channel.invoke<void>('startRewardedInterstitialPreload', {
      'adUnitId': adUnitId,
      'bufferSize': bufferSize,
      'request': request.toMap(),
    });
  }

  /// Polls a ready ad for [adUnitId], or returns `null` if none is available.
  static Future<RewardedInterstitialAd?> poll({
    required String adUnitId,
  }) async {
    final adId = _channel.nextAdId('rewarded_interstitial_preload');
    final result =
        await _channel.invokeMap('pollRewardedInterstitialPreload', {
      'adUnitId': adUnitId,
      'adId': adId,
    });
    if (result['polled'] == true) {
      return RewardedInterstitialAd.internalAdopt(
        adId,
        adUnitId: (result['adUnitId'] as String?) ?? adUnitId,
      );
    }
    return null;
  }

  /// Whether at least one preloaded ad is available for [adUnitId].
  static Future<bool> isAvailable({required String adUnitId}) async {
    final value = await _channel
        .invoke<bool>('isRewardedInterstitialPreloadAvailable', {
      'adUnitId': adUnitId,
    });
    return value ?? false;
  }

  /// Number of preloaded ads currently buffered for [adUnitId].
  static Future<int> count({required String adUnitId}) async {
    final value = await _channel
        .invoke<int>('rewardedInterstitialPreloadCount', {
      'adUnitId': adUnitId,
    });
    return value ?? 0;
  }

  /// Stops preloading and releases buffered ads for [adUnitId].
  static Future<void> destroy({required String adUnitId}) async {
    await _channel.invoke<void>('destroyRewardedInterstitialPreload', {
      'adUnitId': adUnitId,
    });
  }
}
