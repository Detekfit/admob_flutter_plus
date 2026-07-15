# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Full example app exercising every ad type with Google test ad units.
- Unit tests for `AdSize`, banner retry policy, request/config serialization.

### Fixed

- Banner PlatformView dispose races (safe post-dispose callbacks) that could
  crash the host app when leaving a screen that still had banners loading.
- Example app: replaced `TabBarView` with single-section navigation so AdMob
  PlatformViews are fully disposed before another section mounts.
