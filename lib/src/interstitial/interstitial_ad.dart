import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';
import '../core/full_screen_ad.dart';

/// Listener for interstitial full-screen content events.
typedef InterstitialAdListener = FullScreenAdListener;

/// A full-screen interstitial ad.
///
/// Load with [InterstitialAd.load], which throws [AdLoadException] on failure.
/// After a successful [show] the ad is consumed on dismiss/fail-to-show, so no
/// manual [dispose] is required. If you load an ad but never show it, call
/// [dispose] to release native resources.
class InterstitialAd extends FullScreenAd {
  InterstitialAd._(super.adId, {required super.adUnitId});

  /// Internal: adopts a preloaded native ad already registered under [adId].
  ///
  /// Not part of the public API; used by [InterstitialAdPreloader].
  static InterstitialAd internalAdopt(String adId, {required String adUnitId}) =>
      InterstitialAd._(adId, adUnitId: adUnitId);

  @override
  String get showMethod => 'showInterstitial';

  @override
  String get disposeMethod => 'disposeInterstitial';

  /// Shows the interstitial ad. Consumed on dismiss/fail-to-show.
  Future<void> show() => performShow();

  /// Loads an interstitial ad for [adUnitId].
  ///
  /// Completes with a ready-to-show [InterstitialAd], or throws
  /// [AdLoadException] if the load fails.
  static Future<InterstitialAd> load({
    required String adUnitId,
    AdRequest request = const AdRequest(),
  }) async {
    final channel = AdsChannel.instance;
    final adId = channel.nextAdId('interstitial');
    final result = await channel.invokeMap('loadInterstitial', {
      'adId': adId,
      'adUnitId': adUnitId,
      'request': request.toMap(),
    });
    if (result['loaded'] == true) {
      return InterstitialAd._(
        adId,
        adUnitId: (result['adUnitId'] as String?) ?? adUnitId,
      );
    }
    throw AdLoadException(AdError.fromMap(_errorMap(result)));
  }
}

Map<dynamic, dynamic> _errorMap(Map<dynamic, dynamic> result) {
  final error = result['error'];
  if (error is Map) return error;
  return const {'code': -1, 'message': 'Failed to load ad'};
}
