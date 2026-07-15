import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';
import 'native_ad_listener.dart';
import 'native_ad_options.dart';

/// A native ad loaded via the SDK's `NativeAdLoader`.
///
/// Load the ad with [load], then display it using one of the template widgets
/// (`NativeBannerAdView`, `NativeSmallAdView`, `NativeLargeAdView`). Call
/// [dispose] when the ad is no longer needed to release native resources.
class NativeAd {
  /// Creates a [NativeAd]. Call [load] to fetch it.
  NativeAd({
    required this.adUnitId,
    this.request = const AdRequest(),
    this.options = const NativeAdOptions(),
    this.listener,
  }) : adId = AdsChannel.instance.nextAdId('native');

  /// Process-unique identifier used by template widgets to bind to this ad.
  final String adId;

  /// The AdMob ad unit ID.
  final String adUnitId;

  /// Per-request targeting.
  final AdRequest request;

  /// Load-time options (video muting, multiple images, ...).
  final NativeAdOptions options;

  /// Lifecycle callbacks.
  final NativeAdListener? listener;

  bool _loaded = false;
  bool _disposed = false;

  /// Whether the ad has loaded successfully and has not been disposed.
  bool get isLoaded => _loaded && !_disposed;

  /// Loads the native ad. Throws [AdLoadException] on failure.
  Future<void> load() async {
    AdsChannel.instance.register(adId, _handleEvent);
    final result = await AdsChannel.instance.invokeMap('loadNative', {
      'adId': adId,
      'adUnitId': adUnitId,
      'request': request.toMap(),
      'options': options.toMap(),
    });
    if (result['loaded'] == true) {
      _loaded = true;
      listener?.onAdLoaded?.call();
      return;
    }
    AdsChannel.instance.unregister(adId);
    final error = result['error'];
    final adError = AdError.fromMap(
      error is Map ? error : const {'code': -1, 'message': 'Failed to load native ad'},
    );
    listener?.onAdFailedToLoad?.call(adError);
    throw AdLoadException(adError);
  }

  void _handleEvent(String method, dynamic arguments) {
    switch (method) {
      case 'onAdImpression':
        listener?.onAdImpression?.call();
        break;
      case 'onAdClicked':
        listener?.onAdClicked?.call();
        break;
      case 'onAdOpened':
        listener?.onAdOpened?.call();
        break;
      case 'onAdClosed':
        listener?.onAdClosed?.call();
        break;
    }
  }

  /// Releases the native ad. Safe to call more than once.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    AdsChannel.instance.unregister(adId);
    await AdsChannel.instance
        .invoke<void>('disposeNative', {'adId': adId});
  }
}
