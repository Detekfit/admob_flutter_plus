import 'package:admob_flutter_plus/admob_flutter_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AdManager.debugReset);
  tearDown(AdManager.debugReset);

  group('Preload', () {
    test('keeps one id per format and drops an empty id', () {
      AdManager.debugSetPreloads(const [
        Preload.interstitial(''),
        Preload.interstitial('first'),
        Preload.interstitial('second'),
        Preload.rewarded('r'),
        Preload.rewardedInterstitial('ri'),
        Preload.banner('b'),
        Preload.appOpenOnResume('a'),
      ]);
      expect(AdManager.debugPreloadAdUnitId<InterstitialPreload>(), 'second');
      expect(AdManager.debugPreloadAdUnitId<RewardedPreload>(), 'r');
      expect(
        AdManager.debugPreloadAdUnitId<RewardedInterstitialPreload>(),
        'ri',
      );
      expect(AdManager.debugPreloadAdUnitId<BannerPreload>(), 'b');
      expect(AdManager.debugPreloadBannerSize(), const AdSize.anchored());
      expect(AdManager.debugPreloadAdUnitId<AppOpenResumePreload>(), 'a');
      expect(AdManager.preloads, hasLength(5));
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
    test('returns placeholder when Preload.banner is missing', () {
      final widget = AdManager.showPreLoadedBanner(
        size: const AdSize.banner(),
        placeholder: const SizedBox(key: Key('empty')),
      );
      expect(widget, isA<SizedBox>());
      expect((widget as SizedBox).key, const Key('empty'));
    });

    test('returns AdBanner with usePreload when banner id is configured', () {
      AdManager.debugSetPreloads(const [
        Preload.banner('ca-app-pub-test/banner'),
      ]);
      final widget = AdManager.showPreLoadedBanner(height: 100);
      expect(widget, isA<AdBanner>());
      final banner = widget as AdBanner;
      expect(banner.adUnitId, 'ca-app-pub-test/banner');
      expect(banner.usePreload, isTrue);
      expect(banner.size, const AdSize.anchored());
    });
  });

  group('AdNative slot', () {
    Future<void> pumpNative(WidgetTester tester, NativeTemplate template) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topCenter,
            child: AdManager.native(
              adUnitId: 'ca-app-pub-test/native',
              template: template,
              height: 300,
              placeholder: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    testWidgets('stays at zero height while ads are disabled', (tester) async {
      await AdManager.setAdsEnabled(false);
      for (final template in [NativeTemplate.small, NativeTemplate.banner]) {
        await pumpNative(tester, template);
        expect(tester.getSize(find.byType(AdNative)).height, 0);
      }
    });

    testWidgets('stays at zero height when the load fails', (tester) async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const channel = MethodChannel('admob_flutter_plus');
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'loadNative') {
          return <String, dynamic>{
            'loaded': false,
            'error': <String, dynamic>{'code': 3, 'message': 'No fill'},
          };
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      for (final template in [NativeTemplate.small, NativeTemplate.banner]) {
        await pumpNative(tester, template);
        await tester.pump();
        expect(tester.getSize(find.byType(AdNative)).height, 0);
      }
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
        ),
        isTrue,
      );
    });

    test(
      'one load is allowed when the unit differs or no preload id is stored',
      () {
        expect(
          AdManager.debugPreloaderOwnsUnit(
            adUnitId: 'ca-app-pub/other',
            preloadUnitId: 'ca-app-pub/i',
          ),
          isFalse,
        );
        expect(
          AdManager.debugPreloaderOwnsUnit(
            adUnitId: 'ca-app-pub/i',
            preloadUnitId: null,
          ),
          isFalse,
        );
      },
    );
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
      expect(size.toMap(), <String, dynamic>{'type': 'anchored', 'width': -1});
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
