import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';
import '../core/full_screen_ad.dart';
import '../core/rewarded_full_screen_ad.dart';
import 'reward_item.dart';

/// Listener for rewarded full-screen content events.
typedef RewardedAdListener = FullScreenAdListener;

/// A full-screen rewarded ad.
///
/// Load with [RewardedAd.load] (throws [AdLoadException] on failure), then
/// [show], supplying an [OnUserEarnedReward] callback.
class RewardedAd extends RewardedFullScreenAd {
  RewardedAd._(super.adId);

  /// Internal: adopts a preloaded native ad already registered under [adId].
  ///
  /// Not part of the public API; used by [RewardedAdPreloader].
  static RewardedAd internalAdopt(String adId) => RewardedAd._(adId);

  @override
  String get showMethod => 'showRewarded';

  @override
  String get disposeMethod => 'disposeRewarded';

  /// Loads a rewarded ad for [adUnitId].
  static Future<RewardedAd> load({
    required String adUnitId,
    AdRequest request = const AdRequest(),
  }) async {
    final channel = AdsChannel.instance;
    final adId = channel.nextAdId('rewarded');
    final result = await channel.invokeMap('loadRewarded', {
      'adId': adId,
      'adUnitId': adUnitId,
      'request': request.toMap(),
    });
    if (result['loaded'] == true) {
      return RewardedAd._(adId);
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
