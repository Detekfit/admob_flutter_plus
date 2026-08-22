/// Screen corner (or SDK default) for a picture-in-picture ad.
enum PictureInPictureAdPosition {
  /// Uses the SDK's default position (currently bottom-right).
  defaultPosition,

  /// Top-left corner of the screen.
  topLeft,

  /// Top-right corner of the screen.
  topRight,

  /// Bottom-left corner of the screen.
  bottomLeft,

  /// Bottom-right corner of the screen.
  bottomRight,
}

/// Whether a PiP ad is bound to the current Activity or the whole app.
enum PictureInPictureAdPresentationScope {
  /// Dismissed when the host Activity's view hierarchy is gone.
  screen,

  /// Remains visible across screens until hidden or destroyed.
  application,
}

/// Options passed to [PictureInPictureAd.show].
class PictureInPictureAdOptions {
  /// Creates [PictureInPictureAdOptions].
  const PictureInPictureAdOptions({
    this.position = PictureInPictureAdPosition.defaultPosition,
    this.presentationScope = PictureInPictureAdPresentationScope.screen,
  });

  /// Initial on-screen position.
  final PictureInPictureAdPosition position;

  /// Lifecycle binding for the floating ad.
  final PictureInPictureAdPresentationScope presentationScope;

  /// Serializes for the native method channel.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'position': position.name,
        'presentationScope': presentationScope.name,
      };
}
