import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class InterstitialSection extends StatefulWidget {
  const InterstitialSection({super.key, this.config = const AdDemoConfig()});

  final AdDemoConfig config;

  @override
  State<InterstitialSection> createState() => InterstitialSectionState();
}

class InterstitialSectionState extends State<InterstitialSection> {
  InterstitialAd? ad;
  bool preloadStarted = false;
  String status = 'Idle';

  String get adUnitId => AdDemoIds.resolve(AdDemoIds.interstitial, useInvalidUnit: widget.config.useInvalidUnit);

  void log(String message) {
    if (mounted) setState(() => status = message);
  }

  Future<void> load() async {
    try {
      ad = await InterstitialAd.load(adUnitId: adUnitId);
      ad!.listener = InterstitialAdListener(
        onAdDismissedFullScreenContent: () => log('Dismissed'),
        onAdFailedToShowFullScreenContent: (e) => log('Show failed: $e'),
      );
      log('Loaded — ready to show');
    } on AdLoadException catch (e) {
      log('Load failed: ${e.error}');
    }
  }

  Future<void> show() async {
    final current = ad;
    if (current == null) {
      log('Load an ad first');
      return;
    }
    await current.show();
    ad = null;
  }

  Future<void> startPreload() async {
    await InterstitialAdPreloader.start(adUnitId: adUnitId, bufferSize: 2);
    if (!mounted) return;
    setState(() => preloadStarted = true);
    log('Preloader started');
  }

  Future<void> showPreloaded() async {
    final preloaded = await InterstitialAdPreloader.poll(adUnitId: adUnitId);
    if (preloaded == null) {
      log('No preloaded ad available yet');
      return;
    }
    await preloaded.show();
    log('Showed preloaded ad');
  }

  Future<void> destroyPreload() async {
    await InterstitialAdPreloader.destroy(adUnitId: adUnitId);
    if (!mounted) return;
    setState(() => preloadStarted = false);
    log('Preloader destroyed');
  }

  @override
  void dispose() {
    ad?.dispose();
    super.dispose();
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
        Text('Regular', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: load, child: const Text('Load')),
            FilledButton.tonal(onPressed: show, child: const Text('Show')),
          ],
        ),
        const Divider(height: 32),
        Text('Preloader', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: preloadStarted ? null : startPreload, child: const Text('Start')),
            FilledButton.tonal(onPressed: showPreloaded, child: const Text('Poll & Show')),
            OutlinedButton(onPressed: preloadStarted ? destroyPreload : null, child: const Text('Destroy')),
          ],
        ),
      ],
    );
  }
}
