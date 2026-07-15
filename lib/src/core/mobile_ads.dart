import 'package:flutter/services.dart';

import 'ad_error.dart';
import 'channel.dart';
import 'request_configuration.dart';

/// Entry point for initializing and configuring the Google Mobile Ads SDK.
///
/// Call [MobileAds.instance.initialize] once at startup, after obtaining
/// consent if required. The application ID is read from the host app's
/// `AndroidManifest.xml`.
class MobileAds {
  MobileAds._();

  /// The shared [MobileAds] instance.
  static final MobileAds instance = MobileAds._();

  final AdsChannel _channel = AdsChannel.instance;

  bool _initialized = false;

  /// Whether [initialize] has completed successfully.
  bool get isInitialized => _initialized;

  /// Initializes the underlying Google Mobile Ads SDK.
  ///
  /// Safe to call multiple times; subsequent calls are no-ops once
  /// initialization has completed. Reads the AdMob application ID from the
  /// host `AndroidManifest.xml` `com.google.android.gms.ads.APPLICATION_ID`
  /// meta-data entry.
  Future<void> initialize() async {
    if (_initialized) return;
    await _channel.invoke<void>('initialize');
    _initialized = true;
  }

  /// Applies a global [RequestConfiguration] to every subsequent ad request.
  Future<void> setRequestConfiguration(
    RequestConfiguration configuration,
  ) async {
    await _channel.invoke<void>(
      'setRequestConfiguration',
      configuration.toMap(),
    );
  }

  /// Returns the version string of the underlying native SDK.
  Future<String> getVersion() async {
    final version = await _channel.invoke<String>('getVersion');
    return version ?? 'unknown';
  }

  /// Opens the Ad Inspector overlay.
  ///
  /// Only available on registered test devices. Throws an
  /// [AdInspectorException] if the inspector fails to open.
  Future<void> openAdInspector() async {
    try {
      await _channel.invoke<void>('openAdInspector');
    } on PlatformException catch (e) {
      throw AdInspectorException(
        AdError(
          code: int.tryParse(e.code) ?? -1,
          message: e.message ?? 'Failed to open Ad Inspector',
        ),
      );
    }
  }
}
