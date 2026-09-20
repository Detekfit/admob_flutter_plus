import '../core/ad_error.dart';
import '../core/ad_request.dart';
import '../core/channel.dart';
import 'picture_in_picture_ad_listener.dart';
import 'picture_in_picture_ad_options.dart';

/// A picture-in-picture (PiP) ad — open beta in GMA Next-Gen 1.4.0+.
///
/// Displays as a small, draggable floating window. Unlike full-screen ads,
/// [hide] does not consume the instance; you may [show] again until [dispose].
class PictureInPictureAd {
  PictureInPictureAd._(this.adId, {required this.adUnitId}) {
    AdsChannel.instance.register(adId, _handleEvent);
  }

  /// Process-unique identifier used to route native callbacks.
  final String adId;

  /// Ad unit ID used to request this ad (from the native SDK after load).
  final String adUnitId;

  /// Listener for PiP lifecycle events.
  PictureInPictureAdListener? listener;

  bool _disposed = false;

  final AdsChannel _channel = AdsChannel.instance;

  /// Loads a picture-in-picture ad for [adUnitId].
  ///
  /// Completes with a ready-to-show [PictureInPictureAd], or throws
  /// [AdLoadException] if the load fails.
  static Future<PictureInPictureAd> load({
    required String adUnitId,
    AdRequest request = const AdRequest(),
  }) async {
    final channel = AdsChannel.instance;
    final adId = channel.nextAdId('pip');
    final result = await channel.invokeMap('loadPictureInPicture', {
      'adId': adId,
      'adUnitId': adUnitId,
      'request': request.toMap(),
    });
    if (result['loaded'] == true) {
      return PictureInPictureAd._(
        adId,
        adUnitId: (result['adUnitId'] as String?) ?? adUnitId,
      );
    }
    throw AdLoadException(AdError.fromMap(_errorMap(result)));
  }

  /// Shows the floating ad with optional [options] (position and scope).
  Future<void> show({
    PictureInPictureAdOptions options = const PictureInPictureAdOptions(),
  }) async {
    if (_disposed) {
      throw StateError('Cannot show a disposed PictureInPictureAd.');
    }
    await _channel.invoke<void>('showPictureInPicture', {
      'adId': adId,
      'options': options.toMap(),
    });
  }

  /// Hides the floating window without destroying the ad.
  Future<void> hide() async {
    if (_disposed) return;
    await _channel.invoke<void>('hidePictureInPicture', {
      'adId': adId,
    });
  }

  /// Releases native resources. The instance must not be used afterward.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    AdsChannel.instance.unregister(adId);
    await _channel.invoke<void>('disposePictureInPicture', {
      'adId': adId,
    });
  }

  void _handleEvent(String method, dynamic arguments) {
    final map = arguments is Map ? arguments : const <dynamic, dynamic>{};
    switch (method) {
      case 'onAdShown':
        listener?.onAdShown?.call();
        break;
      case 'onAdHidden':
        listener?.onAdHidden?.call();
        break;
      case 'onAdImpression':
        listener?.onAdImpression?.call();
        break;
      case 'onAdClicked':
        listener?.onAdClicked?.call();
        break;
      case 'onAdShowedFullScreenContent':
        listener?.onAdShowedFullScreenContent?.call();
        break;
      case 'onAdDismissedFullScreenContent':
        listener?.onAdDismissedFullScreenContent?.call();
        break;
      case 'onAdFailedToShowFullScreenContent':
        listener?.onAdFailedToShowFullScreenContent?.call(AdError.fromMap(map));
        break;
    }
  }
}

Map<dynamic, dynamic> _errorMap(Map<dynamic, dynamic> result) {
  final error = result['error'];
  if (error is Map) return error;
  return const {'code': -1, 'message': 'Failed to load ad'};
}
