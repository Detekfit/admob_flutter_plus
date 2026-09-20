import '../core/ad_error.dart';

/// Lifecycle callbacks for a [PictureInPictureAd].
///
/// Unlike full-screen formats, PiP ads can be shown and hidden repeatedly
/// without being consumed. Call [PictureInPictureAd.dispose] when finished.
class PictureInPictureAdListener {
  /// Creates a [PictureInPictureAdListener].
  const PictureInPictureAdListener({
    this.onAdShown,
    this.onAdHidden,
    this.onAdImpression,
    this.onAdClicked,
    this.onAdShowedFullScreenContent,
    this.onAdDismissedFullScreenContent,
    this.onAdFailedToShowFullScreenContent,
  });

  /// Called when the floating PiP window appears on screen.
  final void Function()? onAdShown;

  /// Called when the floating window is removed (user or [PictureInPictureAd.hide]).
  final void Function()? onAdHidden;

  /// Called when an impression is recorded.
  final void Function()? onAdImpression;

  /// Called when the ad is clicked.
  final void Function()? onAdClicked;

  /// Called when the ad opens a full-screen overlay (e.g. expanded creative).
  final void Function()? onAdShowedFullScreenContent;

  /// Called when that full-screen overlay is dismissed.
  final void Function()? onAdDismissedFullScreenContent;

  /// Called when showing full-screen content fails.
  final void Function(AdError error)? onAdFailedToShowFullScreenContent;
}
