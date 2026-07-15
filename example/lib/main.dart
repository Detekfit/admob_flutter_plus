import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'sections/app_open_section.dart';
import 'sections/banner_section.dart';
import 'sections/interstitial_section.dart';
import 'sections/native_section.dart';
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

  await MobileAds.instance.setRequestConfiguration(const RequestConfiguration(maxAdContentRating: MaxAdContentRating.g));

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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  BannerDemoConfig _bannerConfig = const BannerDemoConfig();

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.view_agenda_outlined), label: 'Banner'),
    NavigationDestination(icon: Icon(Icons.fullscreen), label: 'Interstitial'),
    NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Rewarded'),
    NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Native'),
    NavigationDestination(icon: Icon(Icons.open_in_browser), label: 'App Open'),
  ];

  bool get _isBannerTab => _index == 0;

  Widget get _section {
    switch (_index) {
      case 0:
        return BannerSection(config: _bannerConfig);
      case 1:
        return const InterstitialSection();
      case 2:
        return const RewardedSection();
      case 3:
        return const NativeSection();
      case 4:
        return const AppOpenSection();
      default:
        return BannerSection(config: _bannerConfig);
    }
  }

  Future<void> _openBannerConfig() async {
    final updated = await showBannerConfigSheet(context, _bannerConfig);
    if (updated != null && mounted) {
      setState(() => _bannerConfig = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admob Flutter+'),
        actions: [
          if (_isBannerTab) IconButton(tooltip: 'Configure banners', icon: const Icon(Icons.edit_outlined), onPressed: _openBannerConfig),
          IconButton(
            tooltip: 'Ad Inspector (test devices)',
            icon: const Icon(Icons.search),
            onPressed: () async {
              try {
                await MobileAds.instance.openAdInspector();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ad Inspector: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: KeyedSubtree(key: ValueKey<Object>('$_index-$_bannerConfig'), child: _section),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          if (index == _index) return;
          setState(() => _index = index);
        },
        destinations: _destinations,
      ),
    );
  }
}
