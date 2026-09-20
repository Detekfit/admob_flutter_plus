# Graph Report - admob_flutter_plus  (2026-09-20)

## Corpus Check
- 92 files · ~86,671 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1006 nodes · 1487 edges · 63 communities (58 shown, 5 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 43 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Banner Ad Controller
- Core Ads Channel
- Demo Ad Constants
- Changelog & Mediation
- Android Banner Views
- Native Ad View Binder
- Picture-in-Picture Ads
- Consent Management
- Android Plugin Bridge
- Public Dart API Barrel
- Native Ad Widgets
- Banner Ad Dart Layer
- App Open Ad Manager
- Interstitial Ad Manager
- Rewarded Interstitial Mgr
- Rewarded Ad Manager
- Native View Factories
- Native Ad View Style
- PiP Ad Dart API
- Ad Preloader Manager
- Demo Banner Section
- Demo PiP Section
- Demo Rewarded Section
- Integration Tests
- Example App Shell
- Demo Native Section
- Demo App Open Section
- Demo Interstitial Section
- App State Notifier
- Rewarded Full-Screen Ads
- Request Configuration Ext
- Android Consent Manager
- Ad Error Mapping
- Demo Section Widgets
- Ad Request Model
- Promo Banner Screenshot
- Initialization Status
- Demo App Screenshot
- Interstitial Preloader
- Rewarded Preloader
- App Open Ad Dart
- Rewarded Interstitial Preload
- Interstitial Ad Dart
- Reward Item Model
- HDPI Launcher Icon
- Full Screen Ad Base
- Package Pubspec Docs
- Core Ad Request Types
- Native Template Views
- MDPI Launcher Icon
- XXHDPI Launcher Icon
- Full Screen Listeners
- XHDPI Launcher Icon
- XXXHDPI Launcher Icon
- Lint Analysis Options
- Example MainActivity
- MethodChannel Isolate
- Generic Type Param

## God Nodes (most connected - your core abstractions)
1. `_` - 29 edges
2. `AdmobFlutterPlusPlugin` - 28 edges
3. `_` - 23 edges
4. `PreloaderManager` - 20 edges
5. `applyRequest()` - 17 edges
6. `NextGenBannerAdView` - 16 edges
7. `AppStateNotifier` - 15 edges
8. `ConsentManager` - 13 edges
9. `NativeTemplateAssetInflater` - 13 edges
10. `EventDispatcher` - 12 edges

## Surprising Connections (you probably didn't know these)
- `PictureInPictureAd` --semantically_similar_to--> `PictureInPictureAd`  [INFERRED] [semantically similar]
  README.md → CHANGELOG.md
- `AdMob Mediation` --semantically_similar_to--> `AdMob Mediation (Next-Gen)`  [INFERRED] [semantically similar]
  README.md → CHANGELOG.md
- `Google Mobile Ads Next-Gen SDK` --semantically_similar_to--> `GMA Next-Gen ads-mobile-sdk`  [INFERRED] [semantically similar]
  README.md → CHANGELOG.md
- `NativeCustomAdView` --semantically_similar_to--> `NativeCustomAdView`  [INFERRED] [semantically similar]
  README.md → CHANGELOG.md
- `AdmobFlutterPlusPlugin` --semantically_similar_to--> `AdmobFlutterPlusPlugin`  [INFERRED] [semantically similar]
  pubspec.yaml → CONTRIBUTING.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Supported ad format surface** — readme_banner_ad_view, readme_interstitial_ad, readme_rewarded_ad, readme_rewarded_interstitial_ad, readme_app_open_ad, readme_picture_in_picture_ad, readme_native_ad [EXTRACTED 1.00]
- **pub.dev release artifacts** — publish_pub_dev_publish, pubspec_pubspec, readme_readme, changelog_changelog [EXTRACTED 1.00]
- **Consent then MobileAds initialize** — readme_ump_consent, readme_mobile_ads, readme_admob_flutter_plus [EXTRACTED 1.00]
- **Example Android Launcher Icon Asset** — example_android_app_src_main_res_mipmap_xxhdpi_ic_launcher_flutter_logo, example_android_app_src_main_res_mipmap_xxhdpi_ic_launcher_android_launcher_icon, example_android_app_src_main_res_mipmap_xxhdpi_ic_launcher_xxhdpi_mipmap [INFERRED 0.85]
- **Flutter Example App Launcher Branding** — example_android_app_src_main_res_mipmap_xxxhdpi_ic_launcher_ic_launcher, example_android_app_src_main_res_mipmap_xxxhdpi_ic_launcher_flutter_logo, example_android_app_src_main_res_mipmap_xxxhdpi_ic_launcher_android_launcher_icon, example_android_app_src_main_res_mipmap_xxxhdpi_ic_launcher_xxxhdpi_mipmap [INFERRED 0.85]
- **Flutter AdMob Nextgen monetization stack** — screenshots_admob_flutter_plus_admob_flutter_plus, screenshots_admob_flutter_plus_flutter, screenshots_admob_flutter_plus_admob_nextgen, screenshots_admob_flutter_plus_app_monetization [EXTRACTED 1.00]
- **Banner Ad Formats Demo** — screenshots_banner_anchored_banner, screenshots_banner_collapsible_banner, screenshots_banner_inline_adaptive_banner, screenshots_banner_medium_rectangle_mrec [EXTRACTED 1.00]
- **Large Native Ad Demo Flow** — screenshots_native_load_native_ad_button, screenshots_native_size_selector, screenshots_native_large_size_template, screenshots_native_test_ad_card, screenshots_native_impression_status [EXTRACTED 1.00]

## Communities (63 total, 5 thin omitted)

### Community 0 - "Banner Ad Controller"
Cohesion: 0.04
Nodes (42): bool get, Exception, adUnitId, attach, BannerAdController, detach, isAttached, refresh (+34 more)

### Community 1 - "Core Ads Channel"
Cohesion: 0.05
Nodes (43): ad_error.dart, channel.dart, initialization_status.dart, InitializationStatus? get, AdEventHandler, _adIdCounter, AdsChannel, _channel (+35 more)

### Community 2 - "Demo Ad Constants"
Cohesion: 0.05
Nodes (44): _, AdDemoIds, anchoredAdaptiveBanner, appId, appOpen, copyWith, fixedSizeBanner, hashCode (+36 more)

### Community 3 - "Changelog & Mediation"
Cohesion: 0.07
Nodes (36): AdMob Mediation (Next-Gen), AgeRestrictedTreatment, GMA Next-Gen ads-mobile-sdk, InitializationStatus / AdapterStatus, Keep a Changelog, NativeCustomAdView, PictureInPictureAd, Semantic Versioning (+28 more)

### Community 4 - "Android Banner Views"
Cohesion: 0.10
Nodes (20): AdView, BannerAdViewFactory, Context, PlatformView, PlatformViewFactory, AdLoadCallback, Context, LoadAdError (+12 more)

### Community 5 - "Native Ad View Binder"
Cohesion: 0.14
Nodes (15): NativeAdView, T, View, NativeAdTags, NativeAdViewBinder, Context, View, NativeTemplateAssetInflater (+7 more)

### Community 6 - "Picture-in-Picture Ads"
Cohesion: 0.09
Nodes (15): Activity, AdLoadCallback, FullScreenContentError, LoadAdError, MethodChannel, PictureInPictureAdManager, AdLoadCallback, PictureInPictureAdEventCallback (+7 more)

### Community 7 - "Consent Management"
Cohesion: 0.06
Nodes (31): dart:async, canRequestAds, _channel, ConsentDebugGeography, ConsentForm, ConsentRequestParameters, ConsentStatus, debugGeography (+23 more)

### Community 8 - "Android Plugin Bridge"
Cohesion: 0.11
Nodes (13): ActivityAware, ActivityPluginBinding, AdmobFlutterPlusPlugin, Activity, Context, MethodCall, MethodChannel, AppOpenAdManager (+5 more)

### Community 9 - "Public Dart API Barrel"
Cohesion: 0.07
Nodes (29): src/app_open/app_open_ad.dart, src/banner/ad_size.dart, src/banner/banner_ad_controller.dart, src/banner/banner_ad_listener.dart, src/banner/banner_ad_view.dart, src/consent/consent.dart, src/core/ad_error.dart, src/core/ad_request.dart (+21 more)

### Community 10 - "Native Ad Widgets"
Cohesion: 0.08
Nodes (26): ad, _assetReady, _bannerViewType, build, createState, creationParams, _customViewType, didUpdateWidget (+18 more)

### Community 11 - "Banner Ad Dart Layer"
Cohesion: 0.08
Nodes (24): ad_size.dart, banner_ad_controller.dart, banner_ad_listener.dart, adUnitId, _asMap, _bannerViewType, build, _buildAndroidPlatformView (+16 more)

### Community 12 - "App Open Ad Manager"
Cohesion: 0.11
Nodes (11): AdLoadCallback, AppOpenAdEventCallback, Activity, AdLoadCallback, FullScreenContentError, LoadAdError, MethodChannel, AdCoordinator (+3 more)

### Community 13 - "Interstitial Ad Manager"
Cohesion: 0.13
Nodes (10): applyRequest(), InterstitialAdManager, AdLoadCallback, InterstitialAdEventCallback, Activity, AdLoadCallback, FullScreenContentError, LoadAdError (+2 more)

### Community 14 - "Rewarded Interstitial Mgr"
Cohesion: 0.13
Nodes (9): Activity, AdLoadCallback, FullScreenContentError, LoadAdError, MethodChannel, RewardedInterstitialAdManager, AdLoadCallback, RewardedInterstitialAdEventCallback (+1 more)

### Community 15 - "Rewarded Ad Manager"
Cohesion: 0.13
Nodes (9): Activity, AdLoadCallback, FullScreenContentError, LoadAdError, MethodChannel, RewardedAdManager, AdLoadCallback, RewardedAdEventCallback (+1 more)

### Community 16 - "Native View Factories"
Cohesion: 0.15
Nodes (13): Context, PlatformView, PlatformViewFactory, NativeAdViewFactory, NativeCustomAdViewFactory, NativeAdView, PlatformView, View (+5 more)

### Community 17 - "Native Ad View Style"
Cohesion: 0.10
Nodes (20): Color?, double?, adBadgeBorderColor, adBadgeColor, adBadgeText, adBadgeTextColor, _argb, cardColor (+12 more)

### Community 18 - "PiP Ad Dart API"
Cohesion: 0.11
Nodes (17): ../../core/ad_error.dart, BannerAdListener, adId, adUnitId, _channel, listener, dispose, _disposed (+9 more)

### Community 20 - "Demo Banner Section"
Cohesion: 0.11
Nodes (18): adUnit, anchoredCollapsible, anchoredController, AnchoredPlacement, BannerSection, BannerSectionState, build, buildAnchoredBanner (+10 more)

### Community 21 - "Demo PiP Section"
Cohesion: 0.11
Nodes (18): ad, adUnitId, build, config, createState, dispose, disposeAd, hide (+10 more)

### Community 22 - "Demo Rewarded Section"
Cohesion: 0.11
Nodes (18): build, config, createState, loadRewarded, loadRewardedInterstitial, log, onReward, pollAndShowRewarded (+10 more)

### Community 23 - "Integration Tests"
Cohesion: 0.15
Nodes (11): main, package:admob_flutter_plus/admob_flutter_plus.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:integration_test/integration_test.dart, main, main, main (+3 more)

### Community 24 - "Example App Shell"
Cohesion: 0.12
Nodes (17): build, createState, demoConfig, destinations, HomePage, HomePageState, main, openAdInspector (+9 more)

### Community 25 - "Demo Native Section"
Cohesion: 0.12
Nodes (16): AdDemoConfig, ad, adUnitId, build, buildTemplate, config, createState, dispose (+8 more)

### Community 26 - "Demo App Open Section"
Cohesion: 0.12
Nodes (16): ad, adUnitId, build, config, createState, dispose, listening, load (+8 more)

### Community 27 - "Demo Interstitial Section"
Cohesion: 0.12
Nodes (15): ../ad_demo_constants.dart, ad, adUnitId, build, config, createState, destroyPreload, dispose (+7 more)

### Community 28 - "App State Notifier"
Cohesion: 0.24
Nodes (6): AppStateNotifier, MethodCall, MethodChannel, DefaultLifecycleObserver, EventChannel, LifecycleOwner

### Community 29 - "Rewarded Full-Screen Ads"
Cohesion: 0.15
Nodes (13): ../../core/full_screen_ad.dart, ../../core/rewarded_full_screen_ad.dart, disposeMethod, internalAdopt, load, show, showMethod, disposeMethod (+5 more)

### Community 30 - "Request Configuration Ext"
Cohesion: 0.21
Nodes (11): applyRequestConfiguration(), resolveAgeRestrictedTreatment(), @Deprecated, reload, AgeRestrictedTreatment, MaxAdContentRating, TagForChildDirectedTreatment, TagForUnderAgeOfConsent (+3 more)

### Community 31 - "Android Consent Manager"
Cohesion: 0.35
Nodes (5): ConsentManager, Activity, MethodCall, MethodChannel, ConsentInformation

### Community 32 - "Ad Error Mapping"
Cohesion: 0.24
Nodes (5): toFlutterMap(), LoadAdError, MethodChannel, NativeAdLoaderCallback, NativeAdEventCallback

### Community 33 - "Demo Section Widgets"
Cohesion: 0.23
Nodes (12): AppOpenSection, AppOpenSectionState, InterstitialSection, InterstitialSectionState, NativeSection, NativeSectionState, RewardedSection, RewardedSectionState (+4 more)

### Community 34 - "Ad Request Model"
Cohesion: 0.17
Nodes (11): categoryExclusions, contentUrl, customTargeting, extras, keywords, neighboringContentUrls, placementId, publisherProvidedId (+3 more)

### Community 35 - "Promo Banner Screenshot"
Cohesion: 0.29
Nodes (12): Ad Format Bottom Navigation, Admob Flutter+, Anchored Banner, Banner Demo Screen, Top/Bottom Banner Position Control, Banner Demo UI Screenshot, Collapsible Banner, Inline Adaptive Banner (+4 more)

### Community 36 - "Initialization Status"
Cohesion: 0.18
Nodes (10): AdapterInitializationState, adapterStatuses, description, fromMap, isComplete, latency, parseAdapterInitializationState, state (+2 more)

### Community 37 - "Demo App Screenshot"
Cohesion: 0.29
Nodes (11): Admob Flutter+ Demo App, Ad Format Bottom Navigation, Flutter Debug Mode Banner, Ad Lifecycle Status: Impression, INSTALL Call-to-Action, Large Native Ad Template, Load Native Ad Button, Native Ad Format (+3 more)

### Community 38 - "Interstitial Preloader"
Cohesion: 0.20
Nodes (9): ../../core/ad_request.dart, ../interstitial/interstitial_ad.dart, _channel, count, destroy, InterstitialAdPreloader, isAvailable, poll (+1 more)

### Community 39 - "Rewarded Preloader"
Cohesion: 0.20
Nodes (9): ../../core/channel.dart, _channel, count, destroy, isAvailable, poll, RewardedAdPreloader, start (+1 more)

### Community 40 - "App Open Ad Dart"
Cohesion: 0.20
Nodes (9): DateTime, disposeMethod, isAvailable, load, _loadTime, maxCacheDuration, show, showMethod (+1 more)

### Community 41 - "Rewarded Interstitial Preload"
Cohesion: 0.20
Nodes (9): _channel, count, destroy, isAvailable, poll, RewardedInterstitialAdPreloader, start, ../rewarded/rewarded_interstitial/rewarded_interstitial_ad.dart (+1 more)

### Community 42 - "Interstitial Ad Dart"
Cohesion: 0.22
Nodes (8): disposeMethod, error, _errorMap, internalAdopt, load, show, showMethod, String get

### Community 43 - "Reward Item Model"
Cohesion: 0.25
Nodes (7): amount, fromMap, OnUserEarnedReward, RewardItem, toString, type, typedef

### Community 44 - "HDPI Launcher Icon"
Cohesion: 0.33
Nodes (7): Android HDPI Launcher Icon (ic_launcher.png), Cyan-to-Navy Blue Palette, Default Flutter Boilerplate Branding, Example App Home-Screen Icon, Flat Layered Polygon Design, Flutter Brand Mark, Geometric Slanted F / Wing Mark

### Community 45 - "Full Screen Ad Base"
Cohesion: 0.29
Nodes (6): full_screen_ad.dart, handleEvent, _onUserEarnedReward, showRewarded, package:flutter/foundation.dart, ../rewarded/reward_item.dart

### Community 46 - "Package Pubspec Docs"
Cohesion: 0.57
Nodes (7): admob_flutter_plus, AdMob Nextgen, Advanced app monetization, Flutter, GitHub, admob_flutter_plus GitHub Promo Banner, pubspec.yaml admob_flutter_plus: latest

### Community 47 - "Core Ad Request Types"
Cohesion: 0.33
Nodes (6): @immutable, AdRequest, AdapterStatus, InitializationStatus, RequestConfiguration, NativeAdViewStyle

### Community 48 - "Native Template Views"
Cohesion: 0.33
Nodes (6): DemoApp, NativeBannerAdView, NativeLargeAdView, NativeSmallAdView, _NativeTemplateView, StatelessWidget

### Community 49 - "MDPI Launcher Icon"
Cohesion: 0.50
Nodes (5): Android Launcher Icon, Example App Branding, Flutter Logo, Geometric Blue Flutter Mark, xxhdpi Mipmap Density

### Community 50 - "XXHDPI Launcher Icon"
Cohesion: 0.50
Nodes (5): Android Launcher Icon, Flutter Logo, Geometric Flutter Brand Mark, ic_launcher.png (xxxhdpi), xxxhdpi Mipmap Density

### Community 51 - "Full Screen Listeners"
Cohesion: 0.40
Nodes (5): AppOpenAdListener, FullScreenAdListener, InterstitialAdListener, RewardedAdListener, RewardedInterstitialAdListener

### Community 52 - "XHDPI Launcher Icon"
Cohesion: 0.67
Nodes (4): Example App Launcher Branding, Flutter Logo, Geometric Blue Flutter Mark, Android Launcher Icon (mdpi)

### Community 53 - "XXXHDPI Launcher Icon"
Cohesion: 0.67
Nodes (4): Android Launcher Icon (ic_launcher), Default Flutter Example Branding, Flutter Logo, mipmap-xhdpi Density Bucket

## Knowledge Gaps
- **403 isolated node(s):** `NativeAdTags`, `BANNER`, `SMALL`, `LARGE`, `main` (+398 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AdRequest` connect `Core Ad Request Types` to `Banner Ad Controller`, `Ad Request Model`, `Banner Ad Dart Layer`, `App Open Ad Manager`, `Interstitial Ad Manager`, `Rewarded Interstitial Mgr`, `Rewarded Ad Manager`, `Ad Preloader Manager`?**
  _High betweenness centrality (0.152) - this node is a cross-community bridge._
- **Why does `applyRequest()` connect `Interstitial Ad Manager` to `Ad Error Mapping`, `Android Banner Views`, `Picture-in-Picture Ads`, `App Open Ad Manager`, `Rewarded Interstitial Mgr`, `Rewarded Ad Manager`, `Ad Preloader Manager`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **Why does `NativeAd` connect `Native Ad View Binder` to `Ad Error Mapping`, `Banner Ad Controller`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **What connects `NativeAdTags`, `BANNER`, `SMALL` to the rest of the system?**
  _403 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Banner Ad Controller` be split into smaller, more focused modules?**
  _Cohesion score 0.044326241134751775 - nodes in this community are weakly interconnected._
- **Should `Core Ads Channel` be split into smaller, more focused modules?**
  _Cohesion score 0.04541062801932367 - nodes in this community are weakly interconnected._
- **Should `Demo Ad Constants` be split into smaller, more focused modules?**
  _Cohesion score 0.04756871035940803 - nodes in this community are weakly interconnected._