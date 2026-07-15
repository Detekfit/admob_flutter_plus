import '../../core/ad_error.dart';
import '../../core/ad_request.dart';
import '../../core/channel.dart';
import '../../core/full_screen_ad.dart';
import '../../core/rewarded_full_screen_ad.dart';
import '../reward_item.dart';

/// Listener for rewarded interstitial full-screen content events.
typedef RewardedInterstitialAdListener = FullScreenAdListener;

/// A full-screen rewarded interstitial ad.
///
/// Combines interstitial behavior with a reward callback. Load with
/// [RewardedInterstitialAd.load], then [show] with an [OnUserEarnedReward].
class RewardedInterstitialAd extends RewardedFullScreenAd {
  RewardedInterstitialAd._(super.adId);

  /// Internal: adopts a preloaded native ad already registered under [adId].
  ///
  /// Not part of the public API; used by [RewardedInterstitialAdPreloader].
  static RewardedInterstitialAd internalAdopt(String adId) =>
      RewardedInterstitialAd._(adId);

  @override
  String get showMethod => 'showRewardedInterstitial';

  @override
  String get disposeMethod => 'disposeRewardedInterstitial';

  /// Loads a rewarded interstitial ad for [adUnitId].
  static Future<RewardedInterstitialAd> load({
    required String adUnitId,
    AdRequest request = const AdRequest(),
  }) async {
    final channel = AdsChannel.instance;
    final adId = channel.nextAdId('rewarded_interstitial');
    final result = await channel.invokeMap('loadRewardedInterstitial', {
      'adId': adId,
      'adUnitId': adUnitId,
      'request': request.toMap(),
    });
    if (result['loaded'] == true) {
      return RewardedInterstitialAd._(adId);
    }
    final error = result['error'];
    throw AdLoadException(
      AdError.fromMap(error is Map ? error : const {'code': -1, 'message': 'Failed to load ad'}),
    );
  }

  /// Shows the ad and reports the earned reward via [onUserEarnedReward].
  Future<void> show({required OnUserEarnedReward onUserEarnedReward}) =>
      showRewarded(onUserEarnedReward: onUserEarnedReward);
}
