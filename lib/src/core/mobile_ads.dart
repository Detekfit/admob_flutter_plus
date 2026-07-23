import 'package:flutter/services.dart';

import 'ad_error.dart';
import 'channel.dart';
import 'initialization_status.dart';
import 'request_configuration.dart';

/// Entry point for initializing and configuring the Google Mobile Ads SDK.
///
/// Call [MobileAds.instance.initialize] once at startup, after obtaining
/// consent if required. The application ID is read from the host app's
/// `AndroidManifest.xml`.
///
/// When using AdMob Mediation, await [initialize] before loading ads so
/// bidding adapters finish initializing. See the package README Mediation
/// section for Next-Gen adapter Gradle setup.
class MobileAds {
  MobileAds._();

  /// The shared [MobileAds] instance.
  static final MobileAds instance = MobileAds._();

  final AdsChannel _channel = AdsChannel.instance;

  bool _initialized = false;
  InitializationStatus? _lastStatus;

  /// Whether [initialize] has completed successfully.
  bool get isInitialized => _initialized;

  /// Adapter statuses from the most recent successful [initialize] call.
  InitializationStatus? get lastInitializationStatus => _lastStatus;

  /// Initializes the underlying Google Mobile Ads SDK (and mediation adapters
  /// present on the Android classpath).
  ///
  /// Safe to call multiple times; subsequent calls return the cached
  /// [InitializationStatus] without re-initializing. Reads the AdMob
  /// application ID from the host `AndroidManifest.xml`
  /// `com.google.android.gms.ads.APPLICATION_ID` meta-data entry.
  ///
  /// Set [disableSdkCrashReporting] to `true` to opt out of the Next-Gen SDK's
  /// default `UncaughtExceptionHandler` (for example when Crashlytics should
  /// own crash reporting exclusively). This flag is only applied on the first
  /// successful [initialize] call.
  Future<InitializationStatus> initialize({
    bool disableSdkCrashReporting = false,
  }) async {
    if (_initialized) {
      return _lastStatus ?? const InitializationStatus(adapterStatuses: {});
    }
    final map = await _channel.invokeMap('initialize', {
      'disableSdkCrashReporting': disableSdkCrashReporting,
    });
    final status = InitializationStatus.fromMap(map);
    _lastStatus = status;
    _initialized = true;
    return status;
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
  ///
  /// To hard-disable Ad Inspector for an app build, add this meta-data to the
  /// host `AndroidManifest.xml` inside `<application>`:
  /// ```xml
  /// <meta-data
  ///     android:name="com.google.android.libraries.ads.mobile.sdk.flag.DISABLE_AD_INSPECTOR"
  ///     android:value="true" />
  /// ```
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
