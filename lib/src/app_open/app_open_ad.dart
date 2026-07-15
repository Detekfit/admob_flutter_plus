import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';
import '../core/full_screen_ad.dart';

/// Listener for app open full-screen content events.
typedef AppOpenAdListener = FullScreenAdListener;

/// A full-screen app open ad.
///
/// App open ads expire four hours after loading per Google's guidance. Use
/// [isAvailable] before [show] to confirm the cached ad is still fresh.
///
/// Drive presentation from process lifecycle transitions via
/// `AppStateEventNotifier`, not Flutter's `WidgetsBindingObserver`, so that
/// showing another full-screen ad is not mistaken for backgrounding.
class AppOpenAd extends FullScreenAd {
  AppOpenAd._(super.adId) : _loadTime = DateTime.now();

  /// Ads are considered expired after this duration.
  static const Duration maxCacheDuration = Duration(hours: 4);

  final DateTime _loadTime;

  @override
  String get showMethod => 'showAppOpen';

  @override
  String get disposeMethod => 'disposeAppOpen';

  /// Shows the app open ad. Consumed on dismiss/fail-to-show.
  Future<void> show() => performShow();

  /// Loads an app open ad for [adUnitId].
  static Future<AppOpenAd> load({
    required String adUnitId,
    AdRequest request = const AdRequest(),
  }) async {
    final channel = AdsChannel.instance;
    final adId = channel.nextAdId('app_open');
    final result = await channel.invokeMap('loadAppOpen', {
      'adId': adId,
      'adUnitId': adUnitId,
      'request': request.toMap(),
    });
    if (result['loaded'] == true) {
      return AppOpenAd._(adId);
    }
    final error = result['error'];
    throw AdLoadException(
      AdError.fromMap(error is Map ? error : const {'code': -1, 'message': 'Failed to load ad'}),
    );
  }

  /// Whether the ad is loaded and has not exceeded [maxCacheDuration].
  Future<bool> isAvailable() async {
    final elapsed = DateTime.now().difference(_loadTime);
    return elapsed < maxCacheDuration;
  }
}
