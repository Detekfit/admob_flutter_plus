import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

/// Where the persistent anchored banner is pinned (never inside a scroll view).
enum AnchoredPlacement { top, bottom }

class BannerSection extends StatefulWidget {
  const BannerSection({super.key, this.config = const AdDemoConfig()});

  final AdDemoConfig config;

  @override
  State<BannerSection> createState() => BannerSectionState();
}

class BannerSectionState extends State<BannerSection> {
  final BannerAdController anchoredController = BannerAdController();

  String status = 'Idle';
  bool anchoredCollapsible = true;
  AnchoredPlacement anchoredPlacement = AnchoredPlacement.bottom;

  String adUnit(String valid) => AdDemoIds.resolve(valid, useInvalidUnit: widget.config.useInvalidUnit);

  /// Collapsible extras must match the real screen edge the banner is pinned to.
  AdRequest get anchoredRequest {
    if (!anchoredCollapsible) return const AdRequest();
    final edge = anchoredPlacement == AnchoredPlacement.top ? 'top' : 'bottom';
    return AdRequest(extras: {'collapsible': edge});
  }

  void setStatus(String value) {
    if (mounted) setState(() => status = value);
  }

  void onAnchoredCollapsibleChanged(bool value) {
    setState(() {
      anchoredCollapsible = value;
      status = value ? 'Reloading collapsible (${anchoredPlacement.name})…' : 'Reloading without collapsible…';
    });
  }

  void onAnchoredPlacementChanged(Set<AnchoredPlacement> selected) {
    setState(() {
      anchoredPlacement = selected.first;
      status = 'Moved anchored banner to ${anchoredPlacement.name}…';
    });
  }

  @override
  void dispose() {
    anchoredController.detach();
    super.dispose();
  }

  Widget buildAnchoredBanner() {
    return Material(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.none,
      child: BannerAdView(
        adUnitId: adUnit(AdDemoIds.anchoredAdaptiveBanner),
        size: AdSize.anchored(),
        // height: 120, // ? Height not required for anchored banners
        controller: anchoredController,
        request: anchoredRequest,
        listener: BannerAdListener(
          onAdLoaded: () => setStatus('Anchored banner loaded (${anchoredPlacement.name})'),
          onAdFailedToLoad: (e) => setStatus('Failed: ${e.code} ${e.message}'),
          onIsCollapsible: (v) => setStatus(
            anchoredCollapsible
                ? 'Loaded at ${anchoredPlacement.name} (requested collapsible, isCollapsible: $v)'
                : 'Loaded at ${anchoredPlacement.name} (collapsible off, isCollapsible: $v)',
          ),
          onAdRefreshed: () => setStatus('Refreshed'),
        ),
        placeholder: placeholder('Anchored failed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Collapsible / anchored banners must stay pinned at a screen edge and must
    // NOT live inside a ListView. Scrollable demos stay in the middle pane only.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (anchoredPlacement == AnchoredPlacement.top) buildAnchoredBanner(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Status: $status', style: Theme.of(context).textTheme.bodySmall),
              if (widget.config.useInvalidUnit) ...[
                const SizedBox(height: 4),
                Text('invalid unit (all ads)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
              const SizedBox(height: 12),
              sectionLabel('Anchored adaptive (persistent)'),
              Text(
                'Pinned outside the scroll area (like an app bar / above bottom nav). '
                'Collapsible only works in this kind of static top/bottom placement.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<AnchoredPlacement>(
                segments: const [
                  ButtonSegment(value: AnchoredPlacement.top, label: Text('Top'), icon: Icon(Icons.vertical_align_top)),
                  ButtonSegment(value: AnchoredPlacement.bottom, label: Text('Bottom'), icon: Icon(Icons.vertical_align_bottom)),
                ],
                selected: {anchoredPlacement},
                onSelectionChanged: onAnchoredPlacementChanged,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Collapsible banner'),
                subtitle: Text(
                  anchoredCollapsible ? 'Request extras: collapsible=${anchoredPlacement.name}' : 'Standard anchored request (no collapsible extras)',
                ),
                value: anchoredCollapsible,
                onChanged: onAnchoredCollapsibleChanged,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(onPressed: anchoredController.refresh, icon: const Icon(Icons.refresh), label: const Text('Refresh anchored')),
              ),
              const Divider(height: 32),
              sectionLabel('Inline adaptive (scroll content)'),
              Text('Inline sizes belong in scrollable content — not for collapsible.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              BannerAdView(
                adUnitId: adUnit(AdDemoIds.inlineAdaptiveBanner),
                size: AdSize.inline(width: 320, maxHeight: 60),
                height: 60,
                placeholder: placeholder('Inline failed'),
              ),
              const Divider(height: 32),
              sectionLabel('Medium rectangle (MREC)'),
              BannerAdView(
                adUnitId: adUnit(AdDemoIds.fixedSizeBanner),
                size: const AdSize.mediumRectangle(),
                height: 250,
                placeholder: placeholder('MREC failed'),
              ),
            ],
          ),
        ),
        if (anchoredPlacement == AnchoredPlacement.bottom) buildAnchoredBanner(),
      ],
    );
  }

  Widget sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget placeholder(String text) => Container(alignment: Alignment.center, color: Colors.grey.shade200, child: Text(text));
}

/// Bottom sheet used from the AppBar edit action to tweak demo options.
Future<AdDemoConfig?> showAdDemoConfigSheet(BuildContext context, AdDemoConfig current) {
  return showModalBottomSheet<AdDemoConfig>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
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
                  Text('Ad demo configuration', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use invalid ad unit'),
                    subtitle: const Text('Applies to every ad type in this demo app'),
                    value: useInvalidUnit,
                    onChanged: (v) => setModalState(() => useInvalidUnit = v),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(AdDemoConfig(useInvalidUnit: useInvalidUnit));
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
