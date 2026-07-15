import 'package:flutter/foundation.dart';

import 'ad_error.dart';
import 'channel.dart';

/// Callbacks shared by every full-screen ad format (interstitial, rewarded,
/// rewarded interstitial, and app open).
class FullScreenAdListener {
  /// Creates a [FullScreenAdListener].
  const FullScreenAdListener({
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
    this.onAdImpression,
    this.onAdClicked,
  });

  /// Called when the ad begins showing full-screen content.
  final void Function()? onAdShowedFullScreenContent;

  /// Called when the ad's full-screen content is dismissed. The ad instance is
  /// consumed after this callback.
  final void Function()? onAdDismissedFullScreenContent;

  /// Called when the ad fails to present its full-screen content. The ad
  /// instance is consumed after this callback.
  final void Function(AdError error)? onAdFailedToShowFullScreenContent;

  /// Called when an impression is recorded.
  final void Function()? onAdImpression;

  /// Called when the ad is clicked.
  final void Function()? onAdClicked;
}

/// Base class implementing the shared load/show/dispose lifecycle for
/// full-screen ads.
///
/// Terminal callbacks (dismiss and failed-to-show) auto-consume the ad, so
/// callers generally do not need to call [dispose] after a successful [show].
abstract class FullScreenAd {
  /// Creates a [FullScreenAd] identified by [adId].
  @protected
  FullScreenAd(this.adId) {
    AdsChannel.instance.register(adId, _handleEvent);
  }

  /// Process-unique identifier used to route native callbacks.
  @protected
  final String adId;

  /// Listener for full-screen content events.
  FullScreenAdListener? listener;

  bool _shown = false;
  bool _disposed = false;

  final AdsChannel _channel = AdsChannel.instance;

  /// Native method name used to show this ad (for example `showInterstitial`).
  @protected
  String get showMethod;

  /// Native method name used to dispose this ad.
  @protected
  String get disposeMethod;

  /// Extra arguments merged into the show invocation by subclasses.
  @protected
  Map<String, dynamic> showArguments() => <String, dynamic>{'adId': adId};

  /// Performs the underlying show invocation, guarding against double-show and
  /// showing a disposed ad. Subclasses expose their own public `show` that
  /// delegates here.
  @protected
  Future<void> performShow() async {
    if (_disposed) {
      throw StateError('Cannot show a disposed ad.');
    }
    if (_shown) {
      throw StateError('This ad has already been shown.');
    }
    _shown = true;
    await _channel.invoke<void>(showMethod, showArguments());
  }

  /// Releases native resources for an ad that was loaded but never shown.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    AdsChannel.instance.unregister(adId);
    await _channel.invoke<void>(disposeMethod, <String, dynamic>{'adId': adId});
  }

  /// Handles a native callback. Subclasses may override to add format-specific
  /// events (for example reward), and must call `super` for shared handling.
  @protected
  @mustCallSuper
  void handleEvent(String method, Map<dynamic, dynamic> arguments) {
    switch (method) {
      case 'onAdShowedFullScreenContent':
        listener?.onAdShowedFullScreenContent?.call();
        break;
      case 'onAdImpression':
        listener?.onAdImpression?.call();
        break;
      case 'onAdClicked':
        listener?.onAdClicked?.call();
        break;
      case 'onAdDismissedFullScreenContent':
        listener?.onAdDismissedFullScreenContent?.call();
        _consume();
        break;
      case 'onAdFailedToShowFullScreenContent':
        listener?.onAdFailedToShowFullScreenContent
            ?.call(AdError.fromMap(arguments));
        _consume();
        break;
    }
  }

  void _handleEvent(String method, dynamic arguments) {
    handleEvent(method, arguments is Map ? arguments : const <dynamic, dynamic>{});
  }

  /// Marks the ad consumed after a terminal callback. Native side releases its
  /// own reference; here we just stop routing callbacks.
  void _consume() {
    if (_disposed) return;
    _disposed = true;
    AdsChannel.instance.unregister(adId);
  }
}
