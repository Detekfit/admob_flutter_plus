/// Options controlling how a native ad and its media are loaded.
class NativeAdOptions {
  /// Creates [NativeAdOptions].
  const NativeAdOptions({
    this.startVideoMuted = true,
    this.requestCustomMuteThisAd = false,
    this.requestMultipleImages = false,
  });

  /// Whether video creatives should start muted.
  final bool startVideoMuted;

  /// Whether to request the "custom mute this ad" feature.
  final bool requestCustomMuteThisAd;

  /// Whether to request multiple images for image assets.
  final bool requestMultipleImages;

  /// Serializes into a channel-friendly map.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'startVideoMuted': startVideoMuted,
        'requestCustomMuteThisAd': requestCustomMuteThisAd,
        'requestMultipleImages': requestMultipleImages,
      };
}
