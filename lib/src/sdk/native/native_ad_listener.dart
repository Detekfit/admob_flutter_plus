import '../core/ad_error.dart';

/// Callbacks for the lifecycle of a [NativeAd].
class NativeAdListener {
  /// Creates a [NativeAdListener].
  const NativeAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdImpression,
    this.onAdClicked,
    this.onAdOpened,
    this.onAdClosed,
  });

  /// Called when the native ad loads.
  final void Function()? onAdLoaded;

  /// Called when loading fails.
  final void Function(AdError error)? onAdFailedToLoad;

  /// Called when an impression is recorded.
  final void Function()? onAdImpression;

  /// Called when the ad is clicked.
  final void Function()? onAdClicked;

  /// Called when the ad opens an overlay.
  final void Function()? onAdOpened;

  /// Called when an opened overlay is dismissed.
  final void Function()? onAdClosed;
}
