import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AdManager.debugReset);
  tearDown(AdManager.debugReset);

  group('PreAdUnitIds', () {
    test('stores optional unit ids', () {
      const units = PreAdUnitIds(
        interstitial: 'i',
        rewarded: 'r',
        rewardedInterstitial: 'ri',
        banner: 'b',
        appOpen: 'a',
      );
      expect(units.interstitial, 'i');
      expect(units.rewarded, 'r');
      expect(units.rewardedInterstitial, 'ri');
      expect(units.banner, 'b');
      expect(units.appOpen, 'a');
    });
  });

  group('AdManager adsEnabled', () {
    test('defaults to true before initialize', () {
      expect(AdManager.adsEnabled, isTrue);
    });

    test('setAdsEnabled toggles the listenable', () async {
      expect(AdManager.adsEnabled, isTrue);
      await AdManager.setAdsEnabled(false);
      expect(AdManager.adsEnabled, isFalse);
      expect(AdManager.adsEnabledListenable.value, isFalse);
      await AdManager.setAdsEnabled(true);
      expect(AdManager.adsEnabled, isTrue);
    });
  });

  group('AdManager.showPreLoadedBanner', () {
    test('returns placeholder when preAdUnitIds.banner is missing', () {
      final widget = AdManager.showPreLoadedBanner(
        size: const AdSize.banner(),
        placeholder: const SizedBox(key: Key('empty')),
      );
      expect(widget, isA<SizedBox>());
      expect((widget as SizedBox).key, const Key('empty'));
    });
  });

  group('AdBanner gating', () {
    testWidgets('hides when adsEnabled is false', (tester) async {
      await AdManager.setAdsEnabled(false);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AdManager.banner(
            adUnitId: 'ca-app-pub-test/banner',
            size: const AdSize.banner(),
            height: 50,
            placeholder: const SizedBox(key: Key('ph'), height: 50),
          ),
        ),
      );
      expect(find.byKey(const Key('ph')), findsOneWidget);
    });
  });

  group('resume latch', () {
    test('starts unset and can be marked after background', () {
      expect(AdManager.debugSawBackground, isFalse);
      AdManager.debugSetSawBackground(true);
      expect(AdManager.debugSawBackground, isTrue);
    });
  });

  group('NativeTemplate', () {
    test('exposes banner small large', () {
      expect(NativeTemplate.values.length, 3);
      expect(NativeTemplate.small.name, 'small');
    });
  });
}
