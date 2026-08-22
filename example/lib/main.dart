import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ad_demo_constants.dart';
import 'sections/app_open_section.dart';
import 'sections/banner_section.dart';
import 'sections/interstitial_section.dart';
import 'sections/native_section.dart';
import 'sections/picture_in_picture_section.dart';
import 'sections/rewarded_section.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Consent must never block the app from starting. If the device is offline
  // or the consent request fails, we still call runApp().
  try {
    await ConsentInformation.instance.requestConsentInfoUpdate(
      const ConsentRequestParameters(
        // Force the EEA form during debug to exercise the consent flow.
        debugGeography: kDebugMode ? ConsentDebugGeography.eea : ConsentDebugGeography.disabled,
      ),
    );
    await ConsentForm.loadAndShowConsentFormIfRequired();
    if (await ConsentInformation.instance.canRequestAds()) {
      await MobileAds.instance.initialize();
    }
  } catch (error) {
    debugPrint('Consent/initialization error (continuing): $error');
    // Attempt initialization anyway so ads can still load where allowed.
    try {
      await MobileAds.instance.initialize();
    } catch (_) {}
  }

  await MobileAds.instance.setRequestConfiguration(
    const RequestConfiguration(maxAdContentRating: MaxAdContentRating.g),
  );

  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'admob_flutter_plus demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.light),
      home: const HomePage(),
    );
  }
}

/// Uses a single active section at a time (not [TabBarView]).
///
/// [TabBarView] keeps neighboring pages (and their PlatformViews) alive while
/// swiping. Destroying AdMob [AndroidView]s mid-load during a tab swipe is a
/// common crash source, so the demo mounts only the selected section.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int tabIndex = 0;
  AdDemoConfig demoConfig = const AdDemoConfig();

  static const destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.view_agenda_outlined), label: 'Banner'),
    NavigationDestination(icon: Icon(Icons.fullscreen), label: 'Interstitial'),
    NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Rewarded'),
    NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Native'),
    NavigationDestination(icon: Icon(Icons.open_in_browser), label: 'App Open'),
    NavigationDestination(icon: Icon(Icons.picture_in_picture_alt_outlined), label: 'PiP'),
  ];

  Widget get section {
    switch (tabIndex) {
      case 0:
        return BannerSection(config: demoConfig);
      case 1:
        return InterstitialSection(config: demoConfig);
      case 2:
        return RewardedSection(config: demoConfig);
      case 3:
        return NativeSection(config: demoConfig);
      case 4:
        return AppOpenSection(config: demoConfig);
      case 5:
        return PictureInPictureSection(config: demoConfig);
      default:
        return BannerSection(config: demoConfig);
    }
  }

  Future<void> openDemoConfig() async {
    final updated = await showAdDemoConfigSheet(context, demoConfig);
    if (updated != null && mounted) {
      setState(() => demoConfig = updated);
    }
  }

  Future<void> openAdInspector() async {
    try {
      await MobileAds.instance.openAdInspector();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ad Inspector: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admob Flutter+'),
        actions: [
          IconButton(tooltip: 'Configure ad demo', icon: const Icon(Icons.edit_outlined), onPressed: openDemoConfig),
          TextButton.icon(onPressed: openAdInspector, icon: const Icon(Icons.bug_report_outlined), label: const Text('Ad Inspector')),
        ],
      ),
      body: KeyedSubtree(key: ValueKey<Object>('$tabIndex-$demoConfig'), child: section),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (index) {
          if (index == tabIndex) return;
          setState(() => tabIndex = index);
        },
        destinations: destinations,
      ),
    );
  }
}
