import 'package:flutter/foundation.dart';

/// Per-request targeting information passed to every ad load.
///
/// Fields map onto the Google Mobile Ads `BaseRequestBuilder` on the native
/// side. All fields are optional; an empty [AdRequest] performs an untargeted
/// request.
@immutable
class AdRequest {
  /// Creates an [AdRequest].
  const AdRequest({
    this.keywords,
    this.customTargeting,
    this.contentUrl,
    this.neighboringContentUrls,
    this.requestAgent,
    this.categoryExclusions,
    this.publisherProvidedId,
    this.placementId,
    this.extras,
  });

  /// Keywords describing the content the ad will be shown alongside.
  final List<String>? keywords;

  /// Custom targeting key/value pairs. Values may be a `String` or a
  /// `List<String>`.
  final Map<String, Object>? customTargeting;

  /// URL of the content the ad is shown next to, for brand safety and
  /// contextual targeting.
  final String? contentUrl;

  /// Up to four URLs of neighboring content for contextual targeting.
  final Set<String>? neighboringContentUrls;

  /// Identifies the request agent (for example, a mediation layer name).
  final String? requestAgent;

  /// Categories to exclude from the request.
  final List<String>? categoryExclusions;

  /// Publisher provided identifier used for frequency capping and targeting.
  final String? publisherProvidedId;

  /// Optional placement identifier, when supported by the SDK.
  final String? placementId;

  /// Extra parameters forwarded to the SDK network extras bundle.
  ///
  /// Banner ads use this for collapsible configuration, for example
  /// `{'collapsible': 'bottom'}`.
  final Map<String, String>? extras;

  /// Serializes this request into a channel-friendly map.
  Map<String, dynamic> toMap() {
    final neighboring = neighboringContentUrls;
    assert(
      neighboring == null || neighboring.length <= 4,
      'neighboringContentUrls supports at most 4 URLs.',
    );
    return <String, dynamic>{
      if (keywords != null) 'keywords': keywords,
      if (customTargeting != null) 'customTargeting': customTargeting,
      if (contentUrl != null) 'contentUrl': contentUrl,
      if (neighboring != null)
        'neighboringContentUrls': neighboring.toList(growable: false),
      if (requestAgent != null) 'requestAgent': requestAgent,
      if (categoryExclusions != null) 'categoryExclusions': categoryExclusions,
      if (publisherProvidedId != null)
        'publisherProvidedId': publisherProvidedId,
      if (placementId != null) 'placementId': placementId,
      if (extras != null) 'extras': extras,
    };
  }
}
