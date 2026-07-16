import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class NativeSection extends StatefulWidget {
  const NativeSection({super.key, this.config = const AdDemoConfig()});

  final AdDemoConfig config;

  @override
  State<NativeSection> createState() => NativeSectionState();
}

enum NativeTemplate { banner, small, large, custom }

class NativeSectionState extends State<NativeSection> {
  NativeAd? ad;
  bool loading = false;
  String status = 'Idle';
  NativeTemplate template = NativeTemplate.large;

  static const NativeAdViewStyle style = NativeAdViewStyle(
    ctaColor: Colors.indigo,
    ctaTextColor: Colors.white,
    ctaCornerRadius: 4,
    titleColor: Colors.black87,
    descriptionColor: Colors.black54,
  );

  String get adUnitId => AdDemoIds.resolve(AdDemoIds.nativeAd, useInvalidUnit: widget.config.useInvalidUnit);

  @override
  void dispose() {
    ad?.dispose();
    super.dispose();
  }

  Future<void> load() async {
    if (!mounted) return;
    setState(() => loading = true);
    await ad?.dispose();
    final next = NativeAd(
      adUnitId: adUnitId,
      options: const NativeAdOptions(startVideoMuted: true),
      listener: NativeAdListener(
        onAdClicked: () {
          if (mounted) setState(() => status = 'Clicked');
        },
        onAdImpression: () {
          if (mounted) setState(() => status = 'Impression');
        },
      ),
    );
    try {
      await next.load();
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() {
        ad = next;
        status = 'Loaded';
        loading = false;
      });
    } on AdLoadException catch (e) {
      await next.dispose();
      if (!mounted) return;
      setState(() {
        status = 'Failed: ${e.error}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ad;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $status'),
        if (widget.config.useInvalidUnit) ...[
          const SizedBox(height: 4),
          Text('invalid unit (all ads)', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: loading ? null : load, icon: const Icon(Icons.download), label: const Text('Load native ad')),
        const SizedBox(height: 8),
        SegmentedButton<NativeTemplate>(
          segments: const [
            ButtonSegment(value: NativeTemplate.banner, label: Text('Banner')),
            ButtonSegment(value: NativeTemplate.small, label: Text('Small')),
            ButtonSegment(value: NativeTemplate.large, label: Text('Large')),
            ButtonSegment(value: NativeTemplate.custom, label: Text('Custom')),
          ],
          selected: {template},
          onSelectionChanged: (selected) => setState(() => template = selected.first),
        ),
        const Divider(height: 32),
        if (current != null && current.isLoaded) buildTemplate(current) else const Text('Load an ad to preview the templates.'),
      ],
    );
  }

  Widget buildTemplate(NativeAd nativeAd) {
    switch (template) {
      case NativeTemplate.banner:
        return NativeBannerAdView(ad: nativeAd, style: style);
      case NativeTemplate.small:
        return NativeSmallAdView(ad: nativeAd, style: style);
      case NativeTemplate.large:
        return NativeLargeAdView(ad: nativeAd, style: style);
      case NativeTemplate.custom:
        return NativeCustomAdView(
          ad: nativeAd,
          templateAsset: 'assets/native/native_ad.xml',
          height: 380,
          style: NativeAdViewStyle(ctaColor: Colors.black87, ctaTextColor: Colors.white, ctaCornerRadius: 8, ctaHeight: 40),
        );
    }
  }
}
