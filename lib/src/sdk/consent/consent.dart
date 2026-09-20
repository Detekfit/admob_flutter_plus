import 'package:flutter/services.dart';

import '../core/ad_error.dart';

/// Debug geography used to force a consent form to appear during testing.
enum ConsentDebugGeography {
  /// Disable debug geography.
  disabled,

  /// Behave as though the device is in the EEA.
  eea,

  /// Behave as though the device is in a region with no regulation in force.
  other,

  /// Behave as though the device is in a regulated US state.
  regulatedUsState,

  /// Behave as though the device is not in the EEA.
  @Deprecated('Use ConsentDebugGeography.other instead')
  notEea,
}

/// Consent status reported by the UMP SDK.
enum ConsentStatus {
  /// Consent status is unknown.
  unknown,

  /// Consent is not required for this user.
  notRequired,

  /// Consent is required but not yet obtained.
  required,

  /// Consent has been obtained.
  obtained,
}

/// Parameters controlling a consent information update request.
class ConsentRequestParameters {
  /// Creates [ConsentRequestParameters].
  const ConsentRequestParameters({
    this.tagForUnderAgeOfConsent = false,
    this.debugGeography = ConsentDebugGeography.disabled,
    this.testDeviceHashedIds = const <String>[],
  });

  /// Whether the user is under the age of consent.
  final bool tagForUnderAgeOfConsent;

  /// Debug geography override for testing consent flows.
  final ConsentDebugGeography debugGeography;

  /// Hashed device IDs that should be treated as test devices.
  final List<String> testDeviceHashedIds;

  /// Serializes into a channel-friendly map.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent,
        'debugGeography': debugGeography.name,
        'testDeviceHashedIds': testDeviceHashedIds,
      };
}

/// Bridge over the UMP (User Messaging Platform) `ConsentInformation`.
class ConsentInformation {
  ConsentInformation._();

  /// The shared [ConsentInformation] instance.
  static final ConsentInformation instance = ConsentInformation._();

  static const MethodChannel _channel =
      MethodChannel('admob_flutter_plus/consent');

  /// Requests an update of the user's consent information.
  ///
  /// Network failures throw a [PlatformException]; callers should wrap startup
  /// consent logic in a `try/catch` so an offline device never blocks
  /// `runApp()`.
  Future<void> requestConsentInfoUpdate([
    ConsentRequestParameters params = const ConsentRequestParameters(),
  ]) async {
    await _channel.invokeMethod<void>(
      'requestConsentInfoUpdate',
      params.toMap(),
    );
  }

  /// Returns the current [ConsentStatus].
  Future<ConsentStatus> getConsentStatus() async {
    final value = await _channel.invokeMethod<String>('getConsentStatus');
    switch (value) {
      case 'notRequired':
        return ConsentStatus.notRequired;
      case 'required':
        return ConsentStatus.required;
      case 'obtained':
        return ConsentStatus.obtained;
      default:
        return ConsentStatus.unknown;
    }
  }

  /// Whether ads can currently be requested given the user's consent choices.
  Future<bool> canRequestAds() async {
    final value = await _channel.invokeMethod<bool>('canRequestAds');
    return value ?? false;
  }

  /// Whether a consent form is available to be shown.
  Future<bool> isConsentFormAvailable() async {
    final value = await _channel.invokeMethod<bool>('isConsentFormAvailable');
    return value ?? false;
  }

  /// Clears all UMP consent state. Intended for debugging only.
  Future<void> reset() async {
    await _channel.invokeMethod<void>('resetConsent');
  }
}

/// Bridge over the UMP `ConsentForm`.
class ConsentForm {
  ConsentForm._();

  static const MethodChannel _channel =
      MethodChannel('admob_flutter_plus/consent');

  /// Loads and, if required, shows the consent form in a single call.
  ///
  /// Throws an [AdError]-wrapped exception if the form fails to load or show.
  static Future<void> loadAndShowConsentFormIfRequired() async {
    try {
      await _channel.invokeMethod<void>('loadAndShowConsentFormIfRequired');
    } on PlatformException catch (e) {
      throw AdError(
        code: int.tryParse(e.code) ?? -1,
        message: e.message ?? 'Failed to present consent form',
      );
    }
  }

  /// Shows the privacy options form (for example, from a settings screen).
  static Future<void> showPrivacyOptionsForm() async {
    await _channel.invokeMethod<void>('showPrivacyOptionsForm');
  }
}
