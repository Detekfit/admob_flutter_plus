import 'package:flutter/foundation.dart';

/// Categories of banner ad size supported by the Next-Gen SDK.
enum AdSizeType {
  /// A fixed IAB standard size (for example 320×50).
  fixed,

  /// Anchored adaptive banner (large API). Maps to
  /// `getLargeAnchoredAdaptiveBannerAdSize` on the native side.
  anchored,

  /// Portrait large anchored adaptive banner.
  anchoredPortrait,

  /// Landscape large anchored adaptive banner.
  anchoredLandscape,

  /// Inline adaptive banner with an explicit width and max height.
  inline,

  /// Inline adaptive banner sized for the current orientation.
  inlineCurrentOrientation,
}

/// Sentinel used for adaptive widths meaning "use the full available width".
const int _fullWidth = -1;

/// Describes the size of a banner ad.
///
/// Prefer the adaptive factories ([AdSize.anchored], [AdSize.inline]) over the
/// fixed IAB sizes. In particular [AdSize.anchored] maps to the current
/// **large anchored adaptive** API (`getLargeAnchoredAdaptiveBannerAdSize`),
/// not the deprecated current-orientation API.
@immutable
class AdSize {
  const AdSize._({
    required this.type,
    this.width,
    this.height,
    this.maxHeight,
  });

  /// Full-width anchored adaptive banner (recommended default).
  ///
  /// Maps to `getLargeAnchoredAdaptiveBannerAdSize(context, width)`. When
  /// [width] is omitted the full screen width is used.
  const AdSize.anchored({int width = _fullWidth})
      : this._(type: AdSizeType.anchored, width: width);

  /// Portrait large anchored adaptive banner.
  ///
  /// Maps to `getLargePortraitAnchoredAdaptiveBannerAdSize(context, width)`.
  const AdSize.anchoredPortrait({int width = _fullWidth})
      : this._(type: AdSizeType.anchoredPortrait, width: width);

  /// Landscape large anchored adaptive banner.
  ///
  /// Maps to `getLargeLandscapeAnchoredAdaptiveBannerAdSize(context, width)`.
  const AdSize.anchoredLandscape({int width = _fullWidth})
      : this._(type: AdSizeType.anchoredLandscape, width: width);

  /// Inline adaptive banner with an explicit [width] and [maxHeight].
  ///
  /// Maps to `getInlineAdaptiveBannerAdSize(width, maxHeight)`.
  const AdSize.inline({required int width, required int maxHeight})
      : this._(type: AdSizeType.inline, width: width, maxHeight: maxHeight);

  /// Inline adaptive banner sized for the current orientation.
  ///
  /// Maps to `getCurrentOrientationInlineAdaptiveBannerAdSize(context, width)`.
  const AdSize.inlineCurrentOrientation({int width = _fullWidth})
      : this._(type: AdSizeType.inlineCurrentOrientation, width: width);

  /// Custom fixed size. Note that custom sizes typically have lower fill.
  const AdSize.fixed({required int width, required int height})
      : this._(type: AdSizeType.fixed, width: width, height: height);

  /// IAB standard banner: 320×50.
  const AdSize.banner()
      : this._(type: AdSizeType.fixed, width: 320, height: 50);

  /// IAB large banner: 320×100.
  const AdSize.largeBanner()
      : this._(type: AdSizeType.fixed, width: 320, height: 100);

  /// IAB medium rectangle (MREC): 300×250.
  const AdSize.mediumRectangle()
      : this._(type: AdSizeType.fixed, width: 300, height: 250);

  /// IAB full banner: 468×60.
  const AdSize.fullBanner()
      : this._(type: AdSizeType.fixed, width: 468, height: 60);

  /// IAB leaderboard: 728×90.
  const AdSize.leaderboard()
      : this._(type: AdSizeType.fixed, width: 728, height: 90);

  /// The size category.
  final AdSizeType type;

  /// Requested width in dp, or `-1` for full width (adaptive sizes only).
  final int? width;

  /// Height in dp for [AdSizeType.fixed] sizes.
  final int? height;

  /// Maximum height in dp for [AdSizeType.inline] sizes.
  final int? maxHeight;

  /// Whether this size is adaptive (height is determined by the SDK at load).
  bool get isAdaptive => type != AdSizeType.fixed;

  /// Suggested reserved height in dp for a fixed size.
  ///
  /// Throws a [StateError] for adaptive sizes, whose height is resolved
  /// natively; use the widget's `height` parameter for those instead.
  int get suggestedHeightDp {
    if (type != AdSizeType.fixed || height == null) {
      throw StateError(
        'suggestedHeightDp is only available for fixed AdSize types. '
        'Adaptive sizes resolve their height natively.',
      );
    }
    return height!;
  }

  /// Serializes into a channel-friendly map consumed by the PlatformView.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'type': type.name,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (maxHeight != null) 'maxHeight': maxHeight,
      };

  @override
  bool operator ==(Object other) =>
      other is AdSize &&
      other.type == type &&
      other.width == width &&
      other.height == height &&
      other.maxHeight == maxHeight;

  @override
  int get hashCode => Object.hash(type, width, height, maxHeight);

  @override
  String toString() =>
      'AdSize(${type.name}, width: $width, height: $height, maxHeight: $maxHeight)';
}
