import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class NativeSection extends StatefulWidget {
  const NativeSection({super.key});

  @override
  State<NativeSection> createState() => _NativeSectionState();
}

enum _Template { banner, small, large }

class _NativeSectionState extends State<NativeSection> {
  NativeAd? _ad;
  bool _loading = false;
  String _status = 'Idle';
  _Template _template = _Template.large;

  static const NativeAdViewStyle _style = NativeAdViewStyle(
    ctaColor: Colors.indigo,
    ctaTextColor: Colors.white,
    ctaCornerRadius: 12,
    titleColor: Colors.black87,
    descriptionColor: Colors.black54,
  );

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    await _ad?.dispose();
    final ad = NativeAd(
      adUnitId: AdDemoIds.nativeAd,
      options: const NativeAdOptions(startVideoMuted: true),
      listener: NativeAdListener(
        onAdClicked: () {
          if (mounted) setState(() => _status = 'Clicked');
        },
        onAdImpression: () {
          if (mounted) setState(() => _status = 'Impression');
        },
      ),
    );
    try {
      await ad.load();
      if (!mounted) {
        await ad.dispose();
        return;
      }
      setState(() {
        _ad = ad;
        _status = 'Loaded';
        _loading = false;
      });
    } on AdLoadException catch (e) {
      await ad.dispose();
      if (!mounted) return;
      setState(() {
        _status = 'Failed: ${e.error}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $_status'),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.download),
          label: const Text('Load native ad'),
        ),
        SegmentedButton<_Template>(
          segments: const [
            ButtonSegment(value: _Template.banner, label: Text('Banner')),
            ButtonSegment(value: _Template.small, label: Text('Small')),
            ButtonSegment(value: _Template.large, label: Text('Large')),
          ],
          selected: {_template},
          onSelectionChanged: (s) => setState(() => _template = s.first),
        ),
        const Divider(height: 32),
        if (ad != null && ad.isLoaded)
          _buildTemplate(ad)
        else
          const Text('Load an ad to preview the templates.'),
      ],
    );
  }

  Widget _buildTemplate(NativeAd ad) {
    switch (_template) {
      case _Template.banner:
        return NativeBannerAdView(ad: ad, style: _style);
      case _Template.small:
        return NativeSmallAdView(ad: ad, style: _style);
      case _Template.large:
        return NativeLargeAdView(ad: ad, style: _style);
    }
  }
}
