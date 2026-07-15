import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class InterstitialSection extends StatefulWidget {
  const InterstitialSection({super.key});

  @override
  State<InterstitialSection> createState() => _InterstitialSectionState();
}

class _InterstitialSectionState extends State<InterstitialSection> {
  InterstitialAd? _ad;
  bool _preloadStarted = false;
  String _status = 'Idle';

  void _log(String message) {
    if (mounted) setState(() => _status = message);
  }

  Future<void> _load() async {
    try {
      _ad = await InterstitialAd.load(adUnitId: AdDemoIds.interstitial);
      _ad!.listener = InterstitialAdListener(
        onAdDismissedFullScreenContent: () => _log('Dismissed'),
        onAdFailedToShowFullScreenContent: (e) => _log('Show failed: $e'),
      );
      _log('Loaded — ready to show');
    } on AdLoadException catch (e) {
      _log('Load failed: ${e.error}');
    }
  }

  Future<void> _show() async {
    final ad = _ad;
    if (ad == null) {
      _log('Load an ad first');
      return;
    }
    await ad.show();
    _ad = null;
  }

  Future<void> _startPreload() async {
    await InterstitialAdPreloader.start(
      adUnitId: AdDemoIds.interstitial,
      bufferSize: 2,
    );
    if (!mounted) return;
    setState(() => _preloadStarted = true);
    _log('Preloader started');
  }

  Future<void> _showPreloaded() async {
    final ad = await InterstitialAdPreloader.poll(
      adUnitId: AdDemoIds.interstitial,
    );
    if (ad == null) {
      _log('No preloaded ad available yet');
      return;
    }
    await ad.show();
    _log('Showed preloaded ad');
  }

  Future<void> _destroyPreload() async {
    await InterstitialAdPreloader.destroy(adUnitId: AdDemoIds.interstitial);
    if (!mounted) return;
    setState(() => _preloadStarted = false);
    _log('Preloader destroyed');
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $_status'),
        const SizedBox(height: 16),
        Text('Regular', style: Theme.of(context).textTheme.titleMedium),
        Wrap(spacing: 8, children: [
          FilledButton(onPressed: _load, child: const Text('Load')),
          FilledButton.tonal(onPressed: _show, child: const Text('Show')),
        ]),
        const Divider(height: 32),
        Text('Preloader', style: Theme.of(context).textTheme.titleMedium),
        Wrap(spacing: 8, children: [
          FilledButton(
            onPressed: _preloadStarted ? null : _startPreload,
            child: const Text('Start'),
          ),
          FilledButton.tonal(
            onPressed: _showPreloaded,
            child: const Text('Poll & Show'),
          ),
          OutlinedButton(
            onPressed: _preloadStarted ? _destroyPreload : null,
            child: const Text('Destroy'),
          ),
        ]),
      ],
    );
  }
}
