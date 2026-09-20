import 'package:flutter/services.dart';

/// Signature for a handler that reacts to a native callback for a given ad.
///
/// [method] is the callback name (for example `onAdDismissedFullScreenContent`)
/// and [arguments] is the decoded payload sent from the native side.
typedef AdEventHandler = void Function(String method, dynamic arguments);

/// Singleton bridge over the main plugin [MethodChannel].
///
/// The native side sends every ad callback back over a single channel and tags
/// the payload with an `adId`. [AdsChannel] demultiplexes those callbacks and
/// dispatches them to the handler registered for that `adId`.
///
/// This keeps the number of platform channels small while still supporting an
/// arbitrary number of concurrently loaded ads.
class AdsChannel {
  AdsChannel._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  /// The shared instance used by every ad class in the package.
  static final AdsChannel instance = AdsChannel._();

  /// Name of the primary method channel shared with the native plugin.
  static const String channelName = 'admob_flutter_plus';

  final MethodChannel _channel = const MethodChannel(channelName);

  final Map<String, AdEventHandler> _handlers = <String, AdEventHandler>{};

  int _adIdCounter = 0;

  /// Generates a process-unique identifier for a new ad instance.
  String nextAdId(String prefix) {
    _adIdCounter += 1;
    return '${prefix}_$_adIdCounter';
  }

  /// Registers [handler] to receive native callbacks tagged with [adId].
  void register(String adId, AdEventHandler handler) {
    _handlers[adId] = handler;
  }

  /// Removes the handler previously registered for [adId].
  void unregister(String adId) {
    _handlers.remove(adId);
  }

  /// Invokes a native method and returns its result.
  ///
  /// [arguments] are merged as-is; callers typically include an `adId` so the
  /// native side can associate the operation with a specific ad instance.
  Future<T?> invoke<T>(String method, [Map<String, dynamic>? arguments]) {
    return _channel.invokeMethod<T>(method, arguments);
  }

  /// Invokes a native method expected to return a map payload.
  Future<Map<String, dynamic>> invokeMap(
    String method, [
    Map<String, dynamic>? arguments,
  ]) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      method,
      arguments,
    );
    return result ?? <String, dynamic>{};
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    final arguments = call.arguments;
    if (arguments is Map) {
      final adId = arguments['adId'];
      if (adId is String) {
        final handler = _handlers[adId];
        if (handler != null) {
          handler(call.method, arguments);
        }
        return null;
      }
    }
    // Unrouted callbacks are ignored; they may target a disposed ad.
    return null;
  }
}
