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

    test('returns AdBanner with usePreload when banner id is configured', () {
      AdManager.debugSetPreAdUnitIds(
        const PreAdUnitIds(banner: 'ca-app-pub-test/banner'),
      );
      AdManager.debugSetPreloadBannerSize(const AdSize.anchored());
      final widget = AdManager.showPreLoadedBanner(height: 100);
      expect(widget, isA<AdBanner>());
      final banner = widget as AdBanner;
      expect(banner.adUnitId, 'ca-app-pub-test/banner');
      expect(banner.usePreload, isTrue);
      expect(banner.size, const AdSize.anchored());
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
    test('built-ins expose name', () {
      expect(NativeTemplate.banner.name, 'banner');
      expect(NativeTemplate.small.name, 'small');
      expect(NativeTemplate.large.name, 'large');
      expect(NativeTemplate.small.isAsset, isFalse);
      expect(NativeTemplate.small.assetPath, isNull);
    });

    test('asset(path) stores path and equality', () {
      const a = NativeTemplate.asset('assets/native/a.xml');
      const b = NativeTemplate.asset('assets/native/a.xml');
      const c = NativeTemplate.asset('assets/native/b.xml');
      expect(a.isAsset, isTrue);
      expect(a.assetPath, 'assets/native/a.xml');
      expect(a.name, 'asset');
      expect(a, b);
      expect(a, isNot(c));
      expect(a, isNot(NativeTemplate.small));
    });
  });

  group('AdManager preload load guard', () {
    test('empty poll does not load when the preloader owns the unit', () {
      expect(
        AdManager.debugPreloaderOwnsUnit(
          adUnitId: 'ca-app-pub/i',
          preloadUnitId: 'ca-app-pub/i',
          preloadEnabled: true,
        ),
        isTrue,
      );
    });

    test('one load is allowed when preload is off or the unit differs', () {
      expect(
        AdManager.debugPreloaderOwnsUnit(
          adUnitId: 'ca-app-pub/other',
          preloadUnitId: 'ca-app-pub/i',
          preloadEnabled: true,
        ),
        isFalse,
      );
      expect(
        AdManager.debugPreloaderOwnsUnit(
          adUnitId: 'ca-app-pub/i',
          preloadUnitId: 'ca-app-pub/i',
          preloadEnabled: false,
        ),
        isFalse,
      );
    });
  });

  group('AdManager consent gate', () {
    test('preloaders start only when ads are allowed and enabled', () {
      expect(
        AdManager.debugMayStartPreloads(canRequestAds: true, adsEnabled: true),
        isTrue,
      );
      expect(
        AdManager.debugMayStartPreloads(canRequestAds: false, adsEnabled: true),
        isFalse,
      );
      expect(
        AdManager.debugMayStartPreloads(canRequestAds: true, adsEnabled: false),
        isFalse,
      );
    });
  });

  group('AdSize.toMap for preload payload', () {
    test('anchored serializes type and width', () {
      const size = AdSize.anchored();
      expect(size.toMap(), <String, dynamic>{
        'type': 'anchored',
        'width': -1,
      });
    });

    test('fixed banner serializes dimensions', () {
      const size = AdSize.banner();
      expect(size.toMap(), <String, dynamic>{
        'type': 'fixed',
        'width': 320,
        'height': 50,
      });
    });
  });
}
