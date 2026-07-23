import 'package:flutter/foundation.dart';

import '../rewarded/reward_item.dart';
import 'full_screen_ad.dart';

/// Base class for full-screen ads that can grant a reward
/// (rewarded and rewarded interstitial).
abstract class RewardedFullScreenAd extends FullScreenAd {
  /// Creates a [RewardedFullScreenAd].
  @protected
  RewardedFullScreenAd(super.adId, {required super.adUnitId});

  OnUserEarnedReward? _onUserEarnedReward;

  /// Shows the ad and invokes [onUserEarnedReward] when a reward is earned.
  Future<void> showRewarded({required OnUserEarnedReward onUserEarnedReward}) {
    _onUserEarnedReward = onUserEarnedReward;
    return performShow();
  }

  @override
  void handleEvent(String method, Map<dynamic, dynamic> arguments) {
    if (method == 'onUserEarnedReward') {
      _onUserEarnedReward?.call(RewardItem.fromMap(arguments));
      return;
    }
    super.handleEvent(method, arguments);
  }
}
