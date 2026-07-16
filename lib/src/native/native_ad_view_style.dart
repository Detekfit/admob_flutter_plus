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
    this.fontFamily,
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

  /// Font family applied to native text assets (headline, body, CTA, …).
  ///
  /// When `null`, template widgets resolve the host app font from
  /// [ThemeData] / [DefaultTextStyle] before creating the PlatformView.
  /// The family name must be available to Android [Typeface] (system font or
  /// a font bundled with the host app).
  final String? fontFamily;

  /// Text shown in the mandatory "Ad" attribution badge.
  final String adBadgeText;

  /// Background color of the ad badge.
  final Color? adBadgeColor;

  /// Text color of the ad badge.
  final Color? adBadgeTextColor;

  /// Border color of the ad badge.
  final Color? adBadgeBorderColor;

  /// Returns a copy with fields replaced when non-null arguments are passed.
  NativeAdViewStyle copyWith({
    Color? cardColor,
    Color? titleColor,
    Color? descriptionColor,
    Color? ctaColor,
    Color? ctaTextColor,
    String? ctaText,
    double? ctaCornerRadius,
    double? ctaHeight,
    String? fontFamily,
    String? adBadgeText,
    Color? adBadgeColor,
    Color? adBadgeTextColor,
    Color? adBadgeBorderColor,
  }) {
    return NativeAdViewStyle(
      cardColor: cardColor ?? this.cardColor,
      titleColor: titleColor ?? this.titleColor,
      descriptionColor: descriptionColor ?? this.descriptionColor,
      ctaColor: ctaColor ?? this.ctaColor,
      ctaTextColor: ctaTextColor ?? this.ctaTextColor,
      ctaText: ctaText ?? this.ctaText,
      ctaCornerRadius: ctaCornerRadius ?? this.ctaCornerRadius,
      ctaHeight: ctaHeight ?? this.ctaHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      adBadgeText: adBadgeText ?? this.adBadgeText,
      adBadgeColor: adBadgeColor ?? this.adBadgeColor,
      adBadgeTextColor: adBadgeTextColor ?? this.adBadgeTextColor,
      adBadgeBorderColor: adBadgeBorderColor ?? this.adBadgeBorderColor,
    );
  }

  /// Fills [fontFamily] from the ambient theme when this style leaves it null.
  NativeAdViewStyle resolve(BuildContext context) {
    if (fontFamily != null && fontFamily!.isNotEmpty) return this;
    final family = resolveAppFontFamily(context);
    if (family == null || family.isEmpty) return this;
    return copyWith(fontFamily: family);
  }

  /// Best-effort font family from the host app's [Theme] / [DefaultTextStyle].
  static String? resolveAppFontFamily(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.fontFamily ??
        theme.textTheme.bodyLarge?.fontFamily ??
        theme.textTheme.titleMedium?.fontFamily ??
        theme.textTheme.headlineSmall?.fontFamily ??
        DefaultTextStyle.of(context).style.fontFamily;
  }

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
        if (fontFamily != null && fontFamily!.isNotEmpty)
          'fontFamily': fontFamily,
        'adBadgeText': adBadgeText,
        if (adBadgeColor != null) 'adBadgeColor': _argb(adBadgeColor),
        if (adBadgeTextColor != null)
          'adBadgeTextColor': _argb(adBadgeTextColor),
        if (adBadgeBorderColor != null)
          'adBadgeBorderColor': _argb(adBadgeBorderColor),
      };
}
