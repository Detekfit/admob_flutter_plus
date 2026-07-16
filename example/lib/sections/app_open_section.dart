import 'dart:async';

import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/material.dart';

import '../ad_demo_constants.dart';

class AppOpenSection extends StatefulWidget {
  const AppOpenSection({super.key, this.config = const AdDemoConfig()});

  final AdDemoConfig config;

  @override
  State<AppOpenSection> createState() => AppOpenSectionState();
}

class AppOpenSectionState extends State<AppOpenSection> {
  AppOpenAd? ad;
  StreamSubscription<AppState>? subscription;
  bool listening = false;
  bool showOnForeground = true;
  String status = 'Idle';

  String get adUnitId => AdDemoIds.resolve(AdDemoIds.appOpen, useInvalidUnit: widget.config.useInvalidUnit);

  void log(String message) {
    if (mounted) setState(() => status = message);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    try {
      ad = await AppOpenAd.load(adUnitId: adUnitId);
      ad!.listener = AppOpenAdListener(
        onAdDismissedFullScreenContent: () {
          log('Dismissed');
          ad = null;
        },
      );
      log('App open ad loaded');
    } on AdLoadException catch (e) {
      log('Load failed: ${e.error}');
    }
  }

  Future<void> startListening() async {
    await AppStateEventNotifier.startListening();
    subscription = AppStateEventNotifier.appStateStream.listen((state) async {
      if (state == AppState.foreground && showOnForeground) {
        await showIfAvailable();
      }
    });
    setState(() => listening = true);
    log('Listening for foreground transitions');
  }

  Future<void> stopListening() async {
    await subscription?.cancel();
    await AppStateEventNotifier.stopListening();
    setState(() => listening = false);
    log('Stopped listening');
  }

  Future<void> showIfAvailable() async {
    final current = ad;
    if (current != null && await current.isAvailable()) {
      await current.show();
      ad = null;
    }
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
        const SizedBox(height: 12),
        const Text(
          'App open ads are driven by process lifecycle. Background the app '
          '(home button) and return to trigger a show.',
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Show on next foreground'),
          value: showOnForeground,
          onChanged: (value) => setState(() => showOnForeground = value),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: load, child: const Text('Load')),
            FilledButton.tonal(onPressed: showIfAvailable, child: const Text('Show now')),
            OutlinedButton(
              onPressed: listening ? stopListening : startListening,
              child: Text(listening ? 'Stop listening' : 'Start listening'),
            ),
          ],
        ),
      ],
    );
  }
}
