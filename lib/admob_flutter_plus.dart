/// A community-maintained Flutter plugin for the Google Mobile Ads Next-Gen
/// SDK on Android.
///
/// This is an **unofficial** package: it is not published, endorsed, or
/// maintained by Google. It wraps the official
/// `com.google.android.libraries.ads.mobile.sdk:ads-mobile-sdk` with an
/// idiomatic, Future-first Dart API.
library;

// ---------------------------------------------------------------------------
// SDK (low-level AdMob API)
// ---------------------------------------------------------------------------

// Core
export 'src/sdk/core/ad_error.dart';
export 'src/sdk/core/ad_request.dart';
export 'src/sdk/core/app_state_event_notifier.dart';
export 'src/sdk/core/full_screen_ad.dart' show FullScreenAdListener;
export 'src/sdk/core/initialization_status.dart';
export 'src/sdk/core/mobile_ads.dart';
export 'src/sdk/core/request_configuration.dart';

// Consent
export 'src/sdk/consent/consent.dart';

// Banner
export 'src/sdk/banner/ad_size.dart';
export 'src/sdk/banner/banner_ad_controller.dart';
export 'src/sdk/banner/banner_ad_listener.dart';
export 'src/sdk/banner/banner_ad_view.dart';

// Interstitial
export 'src/sdk/interstitial/interstitial_ad.dart';

// Rewarded
export 'src/sdk/rewarded/reward_item.dart';
export 'src/sdk/rewarded/rewarded_ad.dart';
export 'src/sdk/rewarded/rewarded_interstitial/rewarded_interstitial_ad.dart';

// App open
export 'src/sdk/app_open/app_open_ad.dart';

// Picture-in-picture (open beta, GMA Next-Gen 1.4.0+)
export 'src/sdk/pip/picture_in_picture_ad.dart';
export 'src/sdk/pip/picture_in_picture_ad_listener.dart';
export 'src/sdk/pip/picture_in_picture_ad_options.dart';

// Native
export 'src/sdk/native/native_ad.dart';
export 'src/sdk/native/native_ad_listener.dart';
export 'src/sdk/native/native_ad_options.dart';
export 'src/sdk/native/native_ad_view_style.dart';
export 'src/sdk/native/native_ad_widgets.dart';
export 'src/sdk/native/native_template_exception.dart';

// Preload
export 'src/sdk/preload/interstitial_ad_preloader.dart';
export 'src/sdk/preload/rewarded_ad_preloader.dart';
export 'src/sdk/preload/rewarded_interstitial_ad_preloader.dart';

// ---------------------------------------------------------------------------
// Manager (convenience helper)
// ---------------------------------------------------------------------------
export 'src/manager/ad_manager.dart';
export 'src/manager/ad_banner.dart';
export 'src/manager/ad_native.dart';
