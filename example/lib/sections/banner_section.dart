import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

/// Runtime options for the banner demo (edited via the AppBar bottom sheet).
class BannerDemoConfig {
  const BannerDemoConfig({this.collapsible = false, this.useInvalidUnit = false});

  final bool collapsible;
  final bool useInvalidUnit;

  BannerDemoConfig copyWith({bool? collapsible, bool? useInvalidUnit}) {
    return BannerDemoConfig(collapsible: collapsible ?? this.collapsible, useInvalidUnit: useInvalidUnit ?? this.useInvalidUnit);
  }

  @override
  bool operator ==(Object other) => other is BannerDemoConfig && other.collapsible == collapsible && other.useInvalidUnit == useInvalidUnit;

  @override
  int get hashCode => Object.hash(collapsible, useInvalidUnit);

  @override
  String toString() => 'BannerDemoConfig(collapsible: $collapsible, useInvalidUnit: $useInvalidUnit)';
}

class BannerSection extends StatefulWidget {
  const BannerSection({super.key, this.config = const BannerDemoConfig()});

  final BannerDemoConfig config;

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final BannerAdController _controller = BannerAdController();

  String _status = 'Idle';

  String get _adUnitId => widget.config.useInvalidUnit ? AdDemoIds.invalidBanner : AdDemoIds.banner;

  AdRequest get _request => AdRequest(extras: widget.config.collapsible ? const {'collapsible': 'bottom'} : null);

  void _setStatus(String value) {
    if (mounted) setState(() => _status = value);
  }

  @override
  void dispose() {
    _controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $_status', style: Theme.of(context).textTheme.bodySmall),
        if (widget.config.collapsible || widget.config.useInvalidUnit) ...[
          const SizedBox(height: 4),
          Text(
            [if (widget.config.collapsible) 'collapsible', if (widget.config.useInvalidUnit) 'invalid unit'].join(' · '),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(onPressed: _controller.refresh, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
        ),
        const Divider(height: 32),
        label('Anchored adaptive (large API)'),
        BannerAdView(
          adUnitId: _adUnitId,
          size: AdSize.anchored(),
          height: 60,
          controller: BannerAdController(),
          request: AdRequest(extras: {'collapsible': 'bottom'}),
          listener: BannerAdListener(
            onAdLoaded: () => _setStatus('Anchored banner loaded'),
            onAdFailedToLoad: (e) => _setStatus('Failed: ${e.code} ${e.message}'),
            onIsCollapsible: (v) => _setStatus('Loaded (collapsible: $v)'),
            onAdRefreshed: () => _setStatus('Refreshed'),
          ),
          placeholder: _placeholder('Anchored failed'),
        ),
        const Divider(height: 32),
        label('Inline adaptive'),
        BannerAdView(adUnitId: _adUnitId, size: AdSize.inline(width: 320, maxHeight: 60), height: 60, placeholder: _placeholder('Inline failed')),
        const Divider(height: 32),
        label('Medium rectangle (MREC)'),
        BannerAdView(adUnitId: _adUnitId, size: const AdSize.mediumRectangle(), height: 250, request: _request, placeholder: _placeholder('MREC failed')),
      ],
    );
  }

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _placeholder(String text) => Container(alignment: Alignment.center, color: Colors.grey.shade200, child: Text(text));
}

/// Bottom sheet used from the AppBar edit action to tweak banner demo options.
Future<BannerDemoConfig?> showBannerConfigSheet(BuildContext context, BannerDemoConfig current) {
  return showModalBottomSheet<BannerDemoConfig>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      var collapsible = current.collapsible;
      var useInvalidUnit = current.useInvalidUnit;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Banner configuration', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Collapsible (bottom)'),
                    subtitle: const Text('Adds AdRequest extras: collapsible=bottom'),
                    value: collapsible,
                    onChanged: (v) => setModalState(() => collapsible = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use invalid ad unit'),
                    subtitle: const Text('Forces load failures for testing'),
                    value: useInvalidUnit,
                    onChanged: (v) => setModalState(() => useInvalidUnit = v),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(BannerDemoConfig(collapsible: collapsible, useInvalidUnit: useInvalidUnit));
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
