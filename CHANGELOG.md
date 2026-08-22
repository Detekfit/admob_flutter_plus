# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.4

### Added

- Picture-in-picture ads (GMA Next-Gen **1.4.0** open beta): `PictureInPictureAd`
  with `load` / `show` / `hide` / `dispose`, `PictureInPictureAdOptions`
  (position + presentation scope), and `PictureInPictureAdListener`
  (`onAdShown` / `onAdHidden` plus shared impression/click/fullscreen callbacks).
- Example app **PiP** tab with Google test unit
  `ca-app-pub-3940256099942544/9657123429`.

### Changed

- Android GMA Next-Gen dependency bumped to `ads-mobile-sdk:1.4.0`.

## 0.1.3

### Added

- AdMob Mediation support for GMA Next-Gen: Gradle excludes for legacy
  `play-services-ads` / `play-services-ads-lite`, and
  `MobileAds.initialize()` now returns `InitializationStatus` with per-adapter
  `AdapterStatus` (`AdapterInitializationState`: `complete`, `failed`,
  `initializing`, `notStarted`, `timedOut`, plus `isComplete`) and
  description/latency. Documented Next-Gen adapter setup (Maven
  `com.google.ads.mediation:*` in the host app — not `gma_mediation_*` /
  `google_mobile_ads`).
- `RequestConfiguration.ageRestrictedTreatment` (`child` / `teen` /
  `unspecified`) matching GMA Next-Gen `setAgeRestrictedTreatment`.
- `ConsentDebugGeography.other` and `regulatedUsState` (UMP debug geography).
- GMA Next-Gen **1.3.0** API surface:
  - `MobileAds.initialize(disableSdkCrashReporting: …)`
  - `Ad.getAdUnitId()` exposed as `adUnitId` on full-screen ads,
    `NativeAd.resolvedAdUnitId`, and `BannerAdController.adUnitId`
  - README docs for the `DISABLE_AD_INSPECTOR` manifest flag

### Changed

- Android library deps bumped: GMA Next-Gen `ads-mobile-sdk:1.3.0`,
  `lifecycle-process:2.11.0`, `kotlinx-coroutines-android:1.11.0` (UMP
  remains `4.0.0`). Plugin AGP stays on Flutter-ecosystem `8.13.1` (not
  host AGP — apps keep their own Gradle/AGP).
- Kotlin callbacks renamed to match AdMob SDK parameter names (silences
  named-argument warnings).

### Deprecated

- `TagForChildDirectedTreatment` / `TagForUnderAgeOfConsent` — use
  `AgeRestrictedTreatment`.
- `ConsentDebugGeography.notEea` — use `ConsentDebugGeography.other`.

### Fixed

- Native template inflater: avoid deprecated `scaledDensity` and redundant
  `MarginLayoutParams` type check.

## 0.1.2

### Added

- Custom native asset templates: support Android `Space` (and
  `android.widget.Space`) in XML inflated by `NativeCustomAdView`.

## 0.1.1

### Fixed

- README screenshots on pub.dev: use absolute GitHub raw image URLs and a fixed
  width for banner/native device screenshots so images render correctly and
  take less vertical space.

## 0.1.0

Initial release. Android-only, built on the Google Mobile Ads **Next-Gen SDK**
(`ads-mobile-sdk:1.2.1`).

### Added

- Core: `MobileAds.initialize`, `getVersion`, `openAdInspector`,
  `setRequestConfiguration`, `AdRequest`, `AdError` types, and an `adId`-based
  callback channel.
- Consent: UMP `ConsentInformation` and `ConsentForm` bridge.
- App state: `AppStateEventNotifier` backed by `ProcessLifecycleOwner`.
- Banner ads: `BannerAdView`, `BannerAdController` (`refresh()`), full `AdSize`
  surface. `AdSize.anchored()` maps to `getLargeAnchoredAdaptiveBannerAdSize`.
- Collapsible banner support via `AdRequest.extras`.
- Interstitial, rewarded, rewarded interstitial, and app open ads with a
  Future-first load API and auto-consuming full-screen lifecycle.
- Preloaders for interstitial, rewarded, and rewarded interstitial ads
  (`InterstitialAdPreloader`, `RewardedAdPreloader`,
  `RewardedInterstitialAdPreloader`) — the formats documented by Google's
  Next-Gen preloading guides.
- Native ads with three prebuilt templates (banner, small, large), styling, and
  Native Validator media deferral for the large template.
- Native ads can use custom XML templates from Flutter assets via
  `NativeCustomAdView` (`android:tag` binding). Throws
  `NativeTemplateException` when the asset is missing or required tags are
  absent. Optional asset tags include advertiser, price, store, stars, and
  media.
- Native ad `NativeAdViewStyle.fontFamily` (optional). When omitted, template
  widgets inherit the host app font from `ThemeData` / `DefaultTextStyle`.
- Full example app exercising every ad type with Google test ad units.
- Unit tests for `AdSize`, banner retry policy, request/config serialization.

### Fixed

- Banner PlatformView dispose races (safe post-dispose callbacks) that could
  crash the host app when leaving a screen that still had banners loading.
- Example app: replaced `TabBarView` with single-section navigation so AdMob
  PlatformViews are fully disposed before another section mounts.
- Custom asset templates no longer call Android `LayoutInflater` on a raw
  `XmlPullParser` (which crashed with `XmlPullAttributes cannot be cast to
XmlBlock$Parser`). Templates are inflated programmatically from the asset
  XML instead.
