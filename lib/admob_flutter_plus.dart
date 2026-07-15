/// A community-maintained Flutter plugin for the Google Mobile Ads Next-Gen
/// SDK on Android.
///
/// This is an **unofficial** package: it is not published, endorsed, or
/// maintained by Google. It wraps the official
/// `com.google.android.libraries.ads.mobile.sdk:ads-mobile-sdk` with an
/// idiomatic, Future-first Dart API.
library;

// Core
export 'src/core/ad_error.dart';
export 'src/core/ad_request.dart';
export 'src/core/app_state_event_notifier.dart';
export 'src/core/full_screen_ad.dart' show FullScreenAdListener;
export 'src/core/mobile_ads.dart';
export 'src/core/request_configuration.dart';

// Consent
export 'src/consent/consent.dart';

// Banner
export 'src/banner/ad_size.dart';
export 'src/banner/banner_ad_controller.dart';
export 'src/banner/banner_ad_listener.dart';
export 'src/banner/banner_ad_view.dart';

// Interstitial
export 'src/interstitial/interstitial_ad.dart';

// Rewarded
export 'src/rewarded/reward_item.dart';
export 'src/rewarded/rewarded_ad.dart';
export 'src/rewarded/rewarded_interstitial/rewarded_interstitial_ad.dart';

// App open
export 'src/app_open/app_open_ad.dart';

// Native
export 'src/native/native_ad.dart';
export 'src/native/native_ad_listener.dart';
export 'src/native/native_ad_options.dart';
export 'src/native/native_ad_view_style.dart';
export 'src/native/native_ad_widgets.dart';

// Preload
export 'src/preload/interstitial_ad_preloader.dart';
export 'src/preload/rewarded_ad_preloader.dart';
export 'src/preload/rewarded_interstitial_ad_preloader.dart';
