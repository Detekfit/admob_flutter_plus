import 'dart:async';

import 'package:flutter/services.dart';

/// Process-level application state.
enum AppState {
  /// The application process moved to the foreground.
  foreground,

  /// The application process moved to the background.
  background,
}

/// Emits process-level foreground/background transitions.
///
/// Unlike Flutter's `WidgetsBindingObserver`, this notifier is backed by
/// Android's `ProcessLifecycleOwner`. This distinction matters for app open
/// ads: showing a fullscreen ad must not be mistaken for the app being
/// backgrounded, which would otherwise cause an app open ad loop.
class AppStateEventNotifier {
  AppStateEventNotifier._();

  static const MethodChannel _methodChannel =
      MethodChannel('admob_flutter_plus/app_state_method');
  static const EventChannel _eventChannel =
      EventChannel('admob_flutter_plus/app_state_event');

  static Stream<AppState>? _appStateStream;

  /// Broadcasts [AppState] transitions.
  ///
  /// Call [startListening] before subscribing.
  static Stream<AppState> get appStateStream {
    return _appStateStream ??= _eventChannel
        .receiveBroadcastStream()
        .map(_mapState)
        .where((state) => state != null)
        .cast<AppState>();
  }

  /// Starts observing process lifecycle events on the native side.
  static Future<void> startListening() async {
    await _methodChannel.invokeMethod<void>('start');
  }

  /// Stops observing process lifecycle events on the native side.
  static Future<void> stopListening() async {
    await _methodChannel.invokeMethod<void>('stop');
  }

  static AppState? _mapState(dynamic event) {
    switch (event) {
      case 'foreground':
        return AppState.foreground;
      case 'background':
        return AppState.background;
      default:
        return null;
    }
  }
}
