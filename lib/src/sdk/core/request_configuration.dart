import 'package:flutter/foundation.dart';

/// Maximum content rating an ad is allowed to have.
enum MaxAdContentRating {
  /// Content suitable for general audiences ("G").
  g,

  /// Content suitable for most audiences with parental guidance ("PG").
  pg,

  /// Content suitable for teen and older audiences ("T").
  t,

  /// Content suitable for mature audiences ("MA").
  ma,

  /// Unspecified — let the SDK choose.
  unspecified,
}

/// Age-restricted treatment applied to ad requests (GMA Next-Gen).
///
/// Replaces the deprecated COPPA / under-age-of-consent tags.
enum AgeRestrictedTreatment {
  /// Ad requests should receive child age treatment.
  child,

  /// Ad requests should receive teen age treatment.
  teen,

  /// No specific age-restricted treatment signal.
  unspecified,
}

/// A three-state tag used for COPPA / GDPR style declarations.
@Deprecated('Use AgeRestrictedTreatment instead')
enum TagForChildDirectedTreatment {
  /// Marks the request as directed toward children.
  yes,

  /// Marks the request as not directed toward children.
  no,

  /// Unspecified.
  unspecified,
}

/// See [TagForChildDirectedTreatment]; applied to users under the age of
/// consent.
@Deprecated('Use AgeRestrictedTreatment instead')
enum TagForUnderAgeOfConsent {
  /// Marks the user as under the age of consent.
  yes,

  /// Marks the user as not under the age of consent.
  no,

  /// Unspecified.
  unspecified,
}

/// Global configuration applied to every ad request.
///
/// Mirrors the GMA `RequestConfiguration`. Apply it once with
/// `MobileAds.setRequestConfiguration`.
@immutable
class RequestConfiguration {
  /// Creates a [RequestConfiguration].
  const RequestConfiguration({
    this.testDeviceIds,
    this.maxAdContentRating,
    this.ageRestrictedTreatment,
    @Deprecated('Use ageRestrictedTreatment instead')
    this.tagForChildDirectedTreatment,
    @Deprecated('Use ageRestrictedTreatment instead')
    this.tagForUnderAgeOfConsent,
  });

  /// Devices that should always be served test ads.
  final List<String>? testDeviceIds;

  /// Maximum content rating for served ads.
  final MaxAdContentRating? maxAdContentRating;

  /// Age-restricted treatment for ad requests (child / teen / unspecified).
  final AgeRestrictedTreatment? ageRestrictedTreatment;

  /// COPPA child-directed treatment tag.
  @Deprecated('Use ageRestrictedTreatment instead')
  final TagForChildDirectedTreatment? tagForChildDirectedTreatment;

  /// Under-age-of-consent tag.
  @Deprecated('Use ageRestrictedTreatment instead')
  final TagForUnderAgeOfConsent? tagForUnderAgeOfConsent;

  /// Serializes this configuration into a channel-friendly map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (testDeviceIds != null) 'testDeviceIds': testDeviceIds,
      if (maxAdContentRating != null)
        'maxAdContentRating': maxAdContentRating!.name,
      if (ageRestrictedTreatment != null)
        'ageRestrictedTreatment': ageRestrictedTreatment!.name,
      // ignore: deprecated_member_use_from_same_package
      if (tagForChildDirectedTreatment != null)
        // ignore: deprecated_member_use_from_same_package
        'tagForChildDirectedTreatment': tagForChildDirectedTreatment!.name,
      // ignore: deprecated_member_use_from_same_package
      if (tagForUnderAgeOfConsent != null)
        // ignore: deprecated_member_use_from_same_package
        'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent!.name,
    };
  }
}
