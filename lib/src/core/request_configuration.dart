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

/// A three-state tag used for COPPA / GDPR style declarations.
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
    this.tagForChildDirectedTreatment,
    this.tagForUnderAgeOfConsent,
  });

  /// Devices that should always be served test ads.
  final List<String>? testDeviceIds;

  /// Maximum content rating for served ads.
  final MaxAdContentRating? maxAdContentRating;

  /// COPPA child-directed treatment tag.
  final TagForChildDirectedTreatment? tagForChildDirectedTreatment;

  /// Under-age-of-consent tag.
  final TagForUnderAgeOfConsent? tagForUnderAgeOfConsent;

  /// Serializes this configuration into a channel-friendly map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (testDeviceIds != null) 'testDeviceIds': testDeviceIds,
      if (maxAdContentRating != null)
        'maxAdContentRating': maxAdContentRating!.name,
      if (tagForChildDirectedTreatment != null)
        'tagForChildDirectedTreatment': tagForChildDirectedTreatment!.name,
      if (tagForUnderAgeOfConsent != null)
        'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent!.name,
    };
  }
}
