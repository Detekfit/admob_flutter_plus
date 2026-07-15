import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class RewardedSection extends StatefulWidget {
  const RewardedSection({super.key});

  @override
  State<RewardedSection> createState() => _RewardedSectionState();
}

class _RewardedSectionState extends State<RewardedSection> {
  RewardedAd? _rewarded;
  RewardedInterstitialAd? _rewardedInterstitial;
  String _status = 'Idle';

  void _log(String message) {
    if (mounted) setState(() => _status = message);
  }

  void _reward(RewardItem reward) =>
      _log('Reward: ${reward.amount} ${reward.type}');

  Future<void> _loadRewarded() async {
    try {
      _rewarded = await RewardedAd.load(adUnitId: AdDemoIds.rewarded);
      _log('Rewarded loaded');
    } on AdLoadException catch (e) {
      _log('Rewarded load failed: ${e.error}');
    }
  }

  Future<void> _showRewarded() async {
    final ad = _rewarded;
    if (ad == null) {
      _log('Load a rewarded ad first');
      return;
    }
    await ad.show(onUserEarnedReward: _reward);
    _rewarded = null;
  }

  Future<void> _loadRewardedInterstitial() async {
    try {
      _rewardedInterstitial = await RewardedInterstitialAd.load(
        adUnitId: AdDemoIds.rewardedInterstitial,
      );
      _log('Rewarded interstitial loaded');
    } on AdLoadException catch (e) {
      _log('RI load failed: ${e.error}');
    }
  }

  Future<void> _showRewardedInterstitial() async {
    final ad = _rewardedInterstitial;
    if (ad == null) {
      _log('Load a rewarded interstitial first');
      return;
    }
    await ad.show(onUserEarnedReward: _reward);
    _rewardedInterstitial = null;
  }

  Future<void> _startRewardedPreload() async {
    await RewardedAdPreloader.start(adUnitId: AdDemoIds.rewarded);
    _log('Rewarded preloader started — poll shortly');
  }

  Future<void> _pollAndShowRewarded() async {
    final ad = await RewardedAdPreloader.poll(adUnitId: AdDemoIds.rewarded);
    if (ad == null) {
      _log('No preloaded rewarded available yet');
      return;
    }
    await ad.show(onUserEarnedReward: _reward);
  }

  Future<void> _preloaderDemo() async {
    await RewardedInterstitialAdPreloader.start(
      adUnitId: AdDemoIds.rewardedInterstitial,
    );
    _log('RI preloader started — poll shortly');
  }

  Future<void> _pollAndShowRI() async {
    final ad = await RewardedInterstitialAdPreloader.poll(
      adUnitId: AdDemoIds.rewardedInterstitial,
    );
    if (ad == null) {
      _log('No preloaded RI available yet');
      return;
    }
    await ad.show(onUserEarnedReward: _reward);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $_status'),
        const SizedBox(height: 16),
        Text('Rewarded', style: Theme.of(context).textTheme.titleMedium),
        Wrap(spacing: 8, children: [
          FilledButton(onPressed: _loadRewarded, child: const Text('Load')),
          FilledButton.tonal(
            onPressed: _showRewarded,
            child: const Text('Show'),
          ),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          OutlinedButton(
            onPressed: _startRewardedPreload,
            child: const Text('Preload start'),
          ),
          OutlinedButton(
            onPressed: _pollAndShowRewarded,
            child: const Text('Poll & show'),
          ),
        ]),
        const Divider(height: 32),
        Text(
          'Rewarded Interstitial',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(spacing: 8, children: [
          FilledButton(
            onPressed: _loadRewardedInterstitial,
            child: const Text('Load'),
          ),
          FilledButton.tonal(
            onPressed: _showRewardedInterstitial,
            child: const Text('Show'),
          ),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          OutlinedButton(
            onPressed: _preloaderDemo,
            child: const Text('Preload start'),
          ),
          OutlinedButton(
            onPressed: _pollAndShowRI,
            child: const Text('Poll & show'),
          ),
        ]),
      ],
    );
  }
}
