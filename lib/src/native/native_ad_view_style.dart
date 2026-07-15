import 'package:flutter/material.dart';

/// Visual styling applied to a native ad template.
///
/// Colors are serialized to 32-bit ARGB integers for the native layer.
@immutable
class NativeAdViewStyle {
  /// Creates a [NativeAdViewStyle].
  const NativeAdViewStyle({
    this.cardColor,
    this.titleColor,
    this.descriptionColor,
    this.ctaColor,
    this.ctaTextColor,
    this.ctaText,
    this.ctaCornerRadius,
    this.ctaHeight,
    this.adBadgeText = 'Ad',
    this.adBadgeColor,
    this.adBadgeTextColor,
    this.adBadgeBorderColor,
  });

  /// Background color of the ad card.
  final Color? cardColor;

  /// Color of the headline text.
  final Color? titleColor;

  /// Color of the body/description text.
  final Color? descriptionColor;

  /// Background color of the call-to-action button.
  final Color? ctaColor;

  /// Text color of the call-to-action button.
  final Color? ctaTextColor;

  /// Overrides the call-to-action button label. When `null`, the ad's own
  /// call-to-action text is used.
  final String? ctaText;

  /// Corner radius (dp) of the call-to-action button.
  final double? ctaCornerRadius;

  /// Height (dp) of the call-to-action button.
  final double? ctaHeight;

  /// Text shown in the mandatory "Ad" attribution badge.
  final String adBadgeText;

  /// Background color of the ad badge.
  final Color? adBadgeColor;

  /// Text color of the ad badge.
  final Color? adBadgeTextColor;

  /// Border color of the ad badge.
  final Color? adBadgeBorderColor;

  static int? _argb(Color? color) => color?.toARGB32();

  /// Serializes into a channel-friendly map.
  Map<String, dynamic> toMap() => <String, dynamic>{
        if (cardColor != null) 'cardColor': _argb(cardColor),
        if (titleColor != null) 'titleColor': _argb(titleColor),
        if (descriptionColor != null)
          'descriptionColor': _argb(descriptionColor),
        if (ctaColor != null) 'ctaColor': _argb(ctaColor),
        if (ctaTextColor != null) 'ctaTextColor': _argb(ctaTextColor),
        if (ctaText != null) 'ctaText': ctaText,
        if (ctaCornerRadius != null) 'ctaCornerRadius': ctaCornerRadius,
        if (ctaHeight != null) 'ctaHeight': ctaHeight,
        'adBadgeText': adBadgeText,
        if (adBadgeColor != null) 'adBadgeColor': _argb(adBadgeColor),
        if (adBadgeTextColor != null)
          'adBadgeTextColor': _argb(adBadgeTextColor),
        if (adBadgeBorderColor != null)
          'adBadgeBorderColor': _argb(adBadgeBorderColor),
      };
}
