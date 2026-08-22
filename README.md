# admob_flutter_plus

[![pub version](https://img.shields.io/badge/pub-0.1.4-blue.svg)](https://pub.dev/packages/admob_flutter_plus)
[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![New](https://img.shields.io/badge/NEW-Picture--in--Picture%20ads-brightgreen)](#picture-in-picture-ads-open-beta-new)

![Admob Flutter Plus Screenshot](https://raw.githubusercontent.com/Detekfit/admob_flutter_plus/main/screenshots/admob_flutter_plus.webp)

A community-maintained Flutter plugin for the **Google Mobile Ads Next-Gen SDK**
on Android — banners, interstitials, rewarded ads, native templates (built-in
or custom XML from Flutter assets), preloaders, UMP consent, and app open ads,
wrapped in an idiomatic, Future-first Dart API.

> **New in 0.1.4:** [Picture-in-picture ads](#picture-in-picture-ads-open-beta-new)
> (GMA Next-Gen open beta) — a floating, draggable ad that stays on screen while
> users keep scrolling, reading, or playing.

> **Unofficial package.** `admob_flutter_plus` is **not** published, endorsed,
> or maintained by Google. It wraps the official
> `com.google.android.libraries.ads.mobile.sdk:ads-mobile-sdk:1.4.0`.

## Screenshots

| Banner | Native |
| --- | --- |
| <img src="https://raw.githubusercontent.com/Detekfit/admob_flutter_plus/main/screenshots/banner.webp" alt="Banner" width="280"> | <img src="https://raw.githubusercontent.com/Detekfit/admob_flutter_plus/main/screenshots/native.webp" alt="Native" width="280"> |

## Platform support

**Android only** for v1. The public Dart API is designed so iOS can be added
later without breaking changes (see the roadmap below). On non-Android
platforms, ad widgets render their `placeholder` (or an empty box) and calls are
no-ops where sensible.

## Requirements

- Flutter `>=3.27.0`, Dart `^3.12.0`
- Android `minSdk 24`, `compileSdk 36`

## Installation

```yaml
dependencies:
  admob_flutter_plus: ^0.1.4
```

### AndroidManifest setup

Add your AdMob application ID to `android/app/src/main/AndroidManifest.xml`
inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" />
```

Optional — hard-disable Ad Inspector for a build (GMA Next-Gen 1.3.0+):

```xml
<meta-data
    android:name="com.google.android.libraries.ads.mobile.sdk.flag.DISABLE_AD_INSPECTOR"
    android:value="true" />
```

Banner video ads require hardware acceleration on the hosting Activity. This is
the default on modern Android; do not disable it.

## Getting started

### Consent + initialization (important)

Always wrap consent in `try/catch` so an offline device (where the consent
request fails) never leaves your app stuck on the splash screen — you must
always reach `runApp()`.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ConsentInformation.instance.requestConsentInfoUpdate();
    await ConsentForm.loadAndShowConsentFormIfRequired();
    if (await ConsentInformation.instance.canRequestAds()) {
      await MobileAds.instance.initialize();
    }
  } catch (_) {
    // Never block startup on consent.
  }
  runApp(const MyApp());
}
```

Other core calls:

```dart
await MobileAds.instance.initialize(
  // Optional: let Crashlytics own crashes exclusively.
  disableSdkCrashReporting: true,
);
await MobileAds.instance.setRequestConfiguration(
  const RequestConfiguration(
    testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
    ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
  ),
);
await MobileAds.instance.openAdInspector(); // test devices only
final version = await MobileAds.instance.getVersion();

// After load, full-screen / native ads expose the SDK-reported ad unit ID:
// interstitial.adUnitId, native.resolvedAdUnitId, bannerController.adUnitId
```

## Banner ads

```dart
BannerAdView(
  adUnitId: 'ca-app-pub-3940256099942544/9214589741',
  size: const AdSize.anchored(),
  height: 100,
  listener: BannerAdListener(
    onAdLoaded: () {},
    onAdFailedToLoad: (e) {},
  ),
)
```

### Sizing guide

`BannerAdView` needs a **bounded height**. Provide `height`, or wrap it in a
`SizedBox`/`AspectRatio`. Adaptive banners resolve their real height natively;
`height` is the reserved slot in the Flutter layout.

| Dart API                                   | Native mapping                                    | Suggested height |
| ------------------------------------------ | ------------------------------------------------- | ---------------- |
| `AdSize.anchored({width})`                 | `getLargeAnchoredAdaptiveBannerAdSize`            | ~100–150 dp      |
| `AdSize.anchoredPortrait({width})`         | `getLargePortraitAnchoredAdaptiveBannerAdSize`    | ~100–150 dp      |
| `AdSize.anchoredLandscape({width})`        | `getLargeLandscapeAnchoredAdaptiveBannerAdSize`   | ~100 dp          |
| `AdSize.inline({width, maxHeight})`        | `getInlineAdaptiveBannerAdSize`                   | `maxHeight`      |
| `AdSize.inlineCurrentOrientation({width})` | `getCurrentOrientationInlineAdaptiveBannerAdSize` | varies           |
| `AdSize.banner()`                          | `AdSize.BANNER`                                   | 50 dp            |
| `AdSize.largeBanner()`                     | `AdSize.LARGE_BANNER`                             | 100 dp           |
| `AdSize.mediumRectangle()`                 | `AdSize.MEDIUM_RECTANGLE`                         | 250 dp           |
| `AdSize.fullBanner()`                      | `AdSize.FULL_BANNER`                              | 60 dp            |
| `AdSize.leaderboard()`                     | `AdSize.LEADERBOARD`                              | 90 dp            |
| `AdSize.fixed(width, height)`              | `AdSize(w, h)`                                    | `height`         |

> **`AdSize.anchored()` uses the large anchored adaptive API**
> (`getLargeAnchoredAdaptiveBannerAdSize`), per the current Next-Gen docs — not
> the deprecated current-orientation API.

### Collapsible banners

Request a collapsible banner via `extras`, and reserve ~100 dp (not 60 dp, which
clips the collapsed slot):

```dart
BannerAdView(
  adUnitId: bannerId,
  size: const AdSize.anchored(),
  height: 100,
  request: const AdRequest(extras: {'collapsible': 'bottom'}), // or 'top'
  listener: BannerAdListener(onIsCollapsible: (v) {}),
)
```

### Refresh

Attach a `BannerAdController` to refresh a mounted banner without recreating
the PlatformView.

```dart
final controller = BannerAdController();

BannerAdView(
  adUnitId: '...',
  size: const AdSize.anchored(),
  height: 100,
  controller: controller,
);

// Later:
controller.refresh();
// controller.reload(); // deprecated — use refresh()
```

> Banner props do not hot-swap into a live PlatformView. When the ad unit or
> collapsible mode changes, recreate the view with
> `key: ValueKey(adUnitId)`.

## Interstitial ads

```dart
final ad = await InterstitialAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/1033173712',
);
ad.listener = InterstitialAdListener(
  onAdDismissedFullScreenContent: () {},
  onAdFailedToShowFullScreenContent: (e) {},
);
await ad.show();
```

`load` throws `AdLoadException` on failure. After `show`, the ad is consumed on
dismiss/fail-to-show, so no manual `dispose()` is needed. If you load but never
show, call `dispose()`.

### Preloader

```dart
await InterstitialAdPreloader.start(adUnitId: id, bufferSize: 2);
final ad = await InterstitialAdPreloader.poll(adUnitId: id);
await ad?.show();
await InterstitialAdPreloader.destroy(adUnitId: id);
// Also: isAvailable(), count()
```

> **Preloading support.** The Next-Gen SDK ships preloader classes for every
> format (`AppOpenAdPreloader`, `BannerAdPreloader`, `InterstitialAdPreloader`,
> `NativeAdPreloader`, `RewardedAdPreloader`, `RewardedInterstitialAdPreloader`),
> but Google's guides document preloading for **interstitial**, **rewarded**, and
> **rewarded interstitial** ads. This plugin exposes those three via
> `InterstitialAdPreloader`, `RewardedAdPreloader`, and
> `RewardedInterstitialAdPreloader`. `bufferSize` must be 1–15 (SDK default 2).

## Rewarded ads

```dart
final ad = await RewardedAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/5224354917',
);
await ad.show(onUserEarnedReward: (reward) {
  print('${reward.amount} ${reward.type}');
});
```

Rewarded ads also support preloading via `RewardedAdPreloader`
(`start` / `poll` / `isAvailable` / `count` / `destroy`).

## Rewarded interstitial ads

```dart
final ad = await RewardedInterstitialAd.load(adUnitId: id);
await ad.show(onUserEarnedReward: (reward) {});
```

A `RewardedInterstitialAdPreloader` mirrors the interstitial preloader.

## App open ads

Drive presentation from **process lifecycle** (not Flutter's
`WidgetsBindingObserver`), so showing another full-screen ad is not mistaken for
backgrounding.

```dart
await AppStateEventNotifier.startListening();
AppStateEventNotifier.appStateStream.listen((state) async {
  if (state == AppState.foreground) {
    final ad = await AppOpenAd.load(adUnitId: appOpenId);
    if (await ad.isAvailable()) await ad.show();
  }
});
```

App open ads expire four hours after loading; `isAvailable()` enforces this.

## Picture-in-picture ads (open beta) ![NEW](https://img.shields.io/badge/NEW-brightgreen)

> **Use case.** Show a small floating ad over content — articles, feeds, or
> gameplay — so users keep using your app while the ad stays visible and
> draggable. Prefer this when a full-screen interstitial would interrupt the
> session.

Requires GMA Next-Gen **1.4.0+**. PiP ads snap to a screen corner and are
**not** consumed when hidden — you can `show` again until `dispose`.

**Test ad unit:** `ca-app-pub-3940256099942544/9657123429`

```dart
final ad = await PictureInPictureAd.load(
  adUnitId: 'ca-app-pub-3940256099942544/9657123429',
);
ad.listener = PictureInPictureAdListener(
  onAdShown: () {},
  onAdHidden: () {},
  onAdImpression: () {},
  onAdClicked: () {},
  onAdFailedToShowFullScreenContent: (e) {},
);
await ad.show(
  options: const PictureInPictureAdOptions(
    position: PictureInPictureAdPosition.topLeft,
    presentationScope: PictureInPictureAdPresentationScope.screen,
  ),
);
await ad.hide(); // removes the window; keeps the instance
await ad.show(); // can show again
await ad.dispose(); // releases native resources when finished
```

| Option | Values | Notes |
| --- | --- | --- |
| **Position** | `defaultPosition`, `topLeft`, `topRight`, `bottomLeft`, `bottomRight` | Initial corner; users can still drag. `defaultPosition` is SDK-managed (currently bottom-right). |
| **Presentation scope** | `screen` (default), `application` | `screen` ends with the Activity. `application` stays across routes — hold a longer-lived reference yourself. |

Lifecycle tips:

- Wire `PictureInPictureAdListener` for `onAdShown` / `onAdHidden` plus the usual impression, click, and full-screen overlay callbacks.
- Call `dispose()` when you are done (and in `State.dispose` for screen-scoped ads).
- There is no PiP preloader in the Next-Gen SDK.

Try it in the example app’s **PiP** tab.

## Native ads

Native ads support **built-in templates** (`NativeBannerAdView`,
`NativeSmallAdView`, `NativeLargeAdView`) and **custom XML templates loaded
from Flutter assets** (`NativeCustomAdView`).

```dart
final nativeAd = NativeAd(
  adUnitId: 'ca-app-pub-3940256099942544/2247696110',
  options: const NativeAdOptions(startVideoMuted: true),
  listener: NativeAdListener(onAdImpression: () {}),
);
await nativeAd.load();
```

Then render a built-in template, or a custom template from assets:

| Widget               | Layout                        | Suggested height |
| -------------------- | ----------------------------- | ---------------- |
| `NativeBannerAdView` | icon + headline + CTA         | ~92 dp           |
| `NativeSmallAdView`  | icon + headline + body + CTA  | ~150 dp          |
| `NativeLargeAdView`  | media + headline + body + CTA | ~380 dp          |
| `NativeCustomAdView` | Flutter-asset Android XML     | you choose       |

```dart
NativeLargeAdView(
  ad: nativeAd,
  style: const NativeAdViewStyle(ctaColor: Colors.indigo),
)
```

### Custom XML templates (Flutter assets)

Export a layout from the community visual builder (or hand-write one), put it
under your app assets, and declare it in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/native/my_template.xml
```

```dart
NativeCustomAdView(
  ad: nativeAd,
  templateAsset: 'assets/native/my_template.xml',
  height: 360,
)
```

Asset XML must bind widgets with `android:tag` (not `@+id`). Required tags:
`ad_headline`, `ad_call_to_action`. Root must be `NativeAdView` (or tag
`ad_view`). Optional: `ad_body`, `ad_app_icon`, `ad_attribution`, `ad_media`,
`ad_advertiser`, `ad_price`, `ad_store`, `ad_stars`. Use literal colors and
fully-qualified `MediaView` / `NativeAdView` class names — `@drawable` and
theme attrs are not resolved from Flutter assets.

If the asset is missing or required tags are absent, the plugin throws
`NativeTemplateException`.

Style via `NativeAdViewStyle` (`cardColor`, `titleColor`, `descriptionColor`,
CTA colors/text/radius/height, `fontFamily`, ad badge text/colors/border).
When `fontFamily` is omitted, template widgets use the host app font from
`ThemeData` / `DefaultTextStyle`. Call `nativeAd.dispose()` when done. A single
`NativeAd` should back only one visible template at a time.

## Request targeting

`AdRequest` maps to the SDK request builder:

```dart
const AdRequest(
  keywords: ['games'],
  customTargeting: {'level': '5', 'genres': ['rpg', 'action']},
  contentUrl: 'https://example.com',
  neighboringContentUrls: {'https://a.com'}, // max 4
  requestAgent: 'my_agent',
  publisherProvidedId: 'ppid',
  extras: {'collapsible': 'bottom'},
)
```

## Migrating from `google_mobile_ads`

- **Future-first loads.** `await InterstitialAd.load(...)` returns the ad or
  throws `AdLoadException` — no `onAdLoaded`/`onAdFailedToLoad` load listeners.
- **No `AdWidget`.** Use `BannerAdView` and the native template widgets
  directly; they are PlatformViews.
- **Listeners** are grouped classes (`BannerAdListener`,
  `FullScreenAdListener`) instead of callback objects passed at load time.
- **`AdSize.anchored()`** replaces the deprecated current-orientation adaptive
  size with the large anchored adaptive API.

## Mediation (AdMob + third-party networks)

GMA Next-Gen **supports AdMob Mediation**. Adapters are discovered automatically
on the Android classpath when you await `MobileAds.instance.initialize()` —
no Dart registration API is required.

Do **not** use the official Flutter packages under
[`gma_mediation_*`](https://github.com/googleads/googleads-mobile-flutter/tree/main/packages/mediation)
or `google_mobile_ads` with this plugin. Those target the **legacy** Play
Services Ads SDK and will conflict with Next-Gen.

### Setup

1. Configure mediation groups and ad sources in the [AdMob console](https://apps.admob.com/).
2. In your **host app** `android/app/build.gradle.kts`, add partner adapter
   artifacts from the
   [Next-Gen mediation guides](https://developers.google.com/admob/android/next-gen/mediation)
   and exclude legacy GMS ads modules (adapters still declare them):

```kotlin
dependencies {
    // Pin the latest version from Google's Next-Gen mediation docs for that network.
    implementation("com.google.ads.mediation:facebook:6.21.0.4")
}

// Only needed when you add mediation adapters (not required for AdMob-only).
configurations.configureEach {
    exclude(group = "com.google.android.gms", module = "play-services-ads")
    exclude(group = "com.google.android.gms", module = "play-services-ads-lite")
}
```

Skip the `configurations.configureEach` excludes if you are **not** using
third-party mediation adapters.

3. Await initialization (and optionally inspect adapter status) before loading ads:

```dart
final status = await MobileAds.instance.initialize();
for (final entry in status.adapterStatuses.entries) {
  // Next-Gen states: complete, failed, initializing, notStarted, timedOut.
  debugPrint(
    '${entry.key}: ${entry.value.state} '
    '(complete=${entry.value.isComplete}, ${entry.value.latency}ms)',
  );
}
```

Partner-specific steps (Meta, AppLovin, Unity, …) are documented per network in
Google’s [Next-Gen mediation](https://developers.google.com/admob/android/next-gen/mediation)
guides.

## Troubleshooting

| Symptom                          | Fix                                                           |
| -------------------------------- | ------------------------------------------------------------- |
| Every request is no-fill         | Use the Google test ad units; new units take time to fill     |
| Crash / "missing application ID" | Add the `APPLICATION_ID` meta-data                            |
| App stuck on splash              | Wrap consent in `try/catch`; always call `runApp()`           |
| Not seeing test ads              | Register your device via `RequestConfiguration.testDeviceIds` |
| Banner clipped                   | Give it a bounded `height` (≥100 dp for anchored/collapsible) |
| Adapter never “READY”            | Next-Gen reports `COMPLETE` (use `status.isComplete`)         |

## Known native SDK notes

The Next-Gen SDK is under active development; APIs may change between versions.
See the
[release notes](https://developers.google.com/admob/android/next-gen/rel-notes).
Notably, large anchored adaptive banner APIs replaced the deprecated
current-orientation APIs in v0.24.0-beta01+ — this plugin uses the new APIs.

## iOS roadmap

iOS is not implemented in v1. The Dart surface is intentionally
platform-agnostic; adding an `ios/` implementation behind the same API is
tracked as future work.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
