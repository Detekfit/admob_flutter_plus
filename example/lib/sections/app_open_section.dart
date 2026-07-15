import 'dart:async';

import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class AppOpenSection extends StatefulWidget {
  const AppOpenSection({super.key});

  @override
  State<AppOpenSection> createState() => _AppOpenSectionState();
}

class _AppOpenSectionState extends State<AppOpenSection> {
  AppOpenAd? _ad;
  StreamSubscription<AppState>? _subscription;
  bool _listening = false;
  bool _showOnForeground = true;
  String _status = 'Idle';

  void _log(String message) {
    if (mounted) setState(() => _status = message);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _ad = await AppOpenAd.load(adUnitId: AdDemoIds.appOpen);
      _ad!.listener = AppOpenAdListener(
        onAdDismissedFullScreenContent: () {
          _log('Dismissed');
          _ad = null;
        },
      );
      _log('App open ad loaded');
    } on AdLoadException catch (e) {
      _log('Load failed: ${e.error}');
    }
  }

  Future<void> _startListening() async {
    await AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen((state) async {
      if (state == AppState.foreground && _showOnForeground) {
        await _showIfAvailable();
      }
    });
    setState(() => _listening = true);
    _log('Listening for foreground transitions');
  }

  Future<void> _stopListening() async {
    await _subscription?.cancel();
    await AppStateEventNotifier.stopListening();
    setState(() => _listening = false);
    _log('Stopped listening');
  }

  Future<void> _showIfAvailable() async {
    final ad = _ad;
    if (ad != null && await ad.isAvailable()) {
      await ad.show();
      _ad = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Status: $_status'),
        const SizedBox(height: 12),
        const Text(
          'App open ads are driven by process lifecycle. Background the app '
          '(home button) and return to trigger a show.',
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Show on next foreground'),
          value: _showOnForeground,
          onChanged: (v) => setState(() => _showOnForeground = v),
        ),
        Wrap(spacing: 8, children: [
          FilledButton(onPressed: _load, child: const Text('Load')),
          FilledButton.tonal(
            onPressed: _showIfAvailable,
            child: const Text('Show now'),
          ),
          OutlinedButton(
            onPressed: _listening ? _stopListening : _startListening,
            child: Text(_listening ? 'Stop listening' : 'Start listening'),
          ),
        ]),
      ],
    );
  }
}
