import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class PictureInPictureSection extends StatefulWidget {
  const PictureInPictureSection({super.key, this.config = const AdDemoConfig()});

  final AdDemoConfig config;

  @override
  State<PictureInPictureSection> createState() => PictureInPictureSectionState();
}

class PictureInPictureSectionState extends State<PictureInPictureSection> {
  PictureInPictureAd? ad;
  String status = 'Idle';
  PictureInPictureAdPosition position = PictureInPictureAdPosition.defaultPosition;
  PictureInPictureAdPresentationScope scope = PictureInPictureAdPresentationScope.screen;

  String get adUnitId =>
      AdDemoIds.resolve(AdDemoIds.pictureInPicture, useInvalidUnit: widget.config.useInvalidUnit);

  void log(String message) {
    if (mounted) setState(() => status = message);
  }

  Future<void> load() async {
    try {
      await ad?.dispose();
      ad = await PictureInPictureAd.load(adUnitId: adUnitId);
      ad!.listener = PictureInPictureAdListener(
        onAdShown: () => log('Shown'),
        onAdHidden: () => log('Hidden'),
        onAdImpression: () => log('Impression'),
        onAdClicked: () => log('Clicked'),
        onAdShowedFullScreenContent: () => log('Full-screen shown'),
        onAdDismissedFullScreenContent: () => log('Full-screen dismissed'),
        onAdFailedToShowFullScreenContent: (e) => log('Full-screen failed: $e'),
      );
      log('Loaded — ready to show');
    } on AdLoadException catch (e) {
      ad = null;
      log('Load failed: ${e.error}');
    }
  }

  Future<void> show() async {
    final current = ad;
    if (current == null) {
      log('Load an ad first');
      return;
    }
    await current.show(
      options: PictureInPictureAdOptions(
        position: position,
        presentationScope: scope,
      ),
    );
  }

  Future<void> hide() async {
    final current = ad;
    if (current == null) {
      log('No ad to hide');
      return;
    }
    await current.hide();
  }

  Future<void> disposeAd() async {
    await ad?.dispose();
    ad = null;
    log('Disposed');
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Open beta (GMA Next-Gen 1.4.0+). Hide keeps the ad; Dispose releases it.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text('Actions', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: load, child: const Text('Load')),
            FilledButton.tonal(onPressed: show, child: const Text('Show')),
            OutlinedButton(onPressed: hide, child: const Text('Hide')),
            OutlinedButton(onPressed: disposeAd, child: const Text('Dispose')),
          ],
        ),
        const Divider(height: 32),
        Text('Position', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: PictureInPictureAdPosition.values.map((value) {
            return ChoiceChip(
              label: Text(_positionLabel(value)),
              selected: position == value,
              onSelected: (_) => setState(() => position = value),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text('Presentation scope', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          children: PictureInPictureAdPresentationScope.values.map((value) {
            return ChoiceChip(
              label: Text(_scopeLabel(value)),
              selected: scope == value,
              onSelected: (_) => setState(() => scope = value),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _positionLabel(PictureInPictureAdPosition value) => switch (value) {
        PictureInPictureAdPosition.defaultPosition => 'DEFAULT',
        PictureInPictureAdPosition.topLeft => 'TOP_LEFT',
        PictureInPictureAdPosition.topRight => 'TOP_RIGHT',
        PictureInPictureAdPosition.bottomLeft => 'BOTTOM_LEFT',
        PictureInPictureAdPosition.bottomRight => 'BOTTOM_RIGHT',
      };

  String _scopeLabel(PictureInPictureAdPresentationScope value) => switch (value) {
        PictureInPictureAdPresentationScope.screen => 'SCREEN',
        PictureInPictureAdPresentationScope.application => 'APPLICATION',
      };
}
