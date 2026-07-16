import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class RewardedSection extends StatefulWidget {
  const RewardedSection({super.key, this.config = const AdDemoConfig()});

  final AdDemoConfig config;

  @override
  State<RewardedSection> createState() => RewardedSectionState();
}

class RewardedSectionState extends State<RewardedSection> {
  RewardedAd? rewarded;
  RewardedInterstitialAd? rewardedInterstitial;
  String status = 'Idle';

  String get rewardedAdUnitId =>
      AdDemoIds.resolve(AdDemoIds.rewarded, useInvalidUnit: widget.config.useInvalidUnit);

  String get rewardedInterstitialAdUnitId =>
      AdDemoIds.resolve(AdDemoIds.rewardedInterstitial, useInvalidUnit: widget.config.useInvalidUnit);

  void log(String message) {
    if (mounted) setState(() => status = message);
  }

  void onReward(RewardItem reward) => log('Reward: ${reward.amount} ${reward.type}');

  Future<void> loadRewarded() async {
    try {
      rewarded = await RewardedAd.load(adUnitId: rewardedAdUnitId);
      log('Rewarded loaded');
    } on AdLoadException catch (e) {
      log('Rewarded load failed: ${e.error}');
    }
  }

  Future<void> showRewarded() async {
    final current = rewarded;
    if (current == null) {
      log('Load a rewarded ad first');
      return;
    }
    await current.show(onUserEarnedReward: onReward);
    rewarded = null;
  }

  Future<void> loadRewardedInterstitial() async {
    try {
      rewardedInterstitial = await RewardedInterstitialAd.load(adUnitId: rewardedInterstitialAdUnitId);
      log('Rewarded interstitial loaded');
    } on AdLoadException catch (e) {
      log('RI load failed: ${e.error}');
    }
  }

  Future<void> showRewardedInterstitial() async {
    final current = rewardedInterstitial;
    if (current == null) {
      log('Load a rewarded interstitial first');
      return;
    }
    await current.show(onUserEarnedReward: onReward);
    rewardedInterstitial = null;
  }

  Future<void> startRewardedPreload() async {
    await RewardedAdPreloader.start(adUnitId: rewardedAdUnitId);
    log('Rewarded preloader started — poll shortly');
  }

  Future<void> pollAndShowRewarded() async {
    final preloaded = await RewardedAdPreloader.poll(adUnitId: rewardedAdUnitId);
    if (preloaded == null) {
      log('No preloaded rewarded available yet');
      return;
    }
    await preloaded.show(onUserEarnedReward: onReward);
  }

  Future<void> startRewardedInterstitialPreload() async {
    await RewardedInterstitialAdPreloader.start(adUnitId: rewardedInterstitialAdUnitId);
    log('RI preloader started — poll shortly');
  }

  Future<void> pollAndShowRewardedInterstitial() async {
    final preloaded = await RewardedInterstitialAdPreloader.poll(adUnitId: rewardedInterstitialAdUnitId);
    if (preloaded == null) {
      log('No preloaded RI available yet');
      return;
    }
    await preloaded.show(onUserEarnedReward: onReward);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $status'),
        if (widget.config.useInvalidUnit) ...[
          const SizedBox(height: 4),
          Text(
            'invalid unit (all ads)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
        const SizedBox(height: 16),
        Text('Rewarded', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: loadRewarded, child: const Text('Load')),
            FilledButton.tonal(onPressed: showRewarded, child: const Text('Show')),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(onPressed: startRewardedPreload, child: const Text('Preload start')),
            OutlinedButton(onPressed: pollAndShowRewarded, child: const Text('Poll & show')),
          ],
        ),
        const Divider(height: 32),
        Text('Rewarded Interstitial', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: loadRewardedInterstitial, child: const Text('Load')),
            FilledButton.tonal(onPressed: showRewardedInterstitial, child: const Text('Show')),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(onPressed: startRewardedInterstitialPreload, child: const Text('Preload start')),
            OutlinedButton(onPressed: pollAndShowRewardedInterstitial, child: const Text('Poll & show')),
          ],
        ),
      ],
    );
  }
}
