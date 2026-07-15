import '../core/ad_error.dart';

/// Callbacks for the lifecycle of a [BannerAdView].
class BannerAdListener {
  /// Creates a [BannerAdListener].
  const BannerAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdRefreshed,
    this.onAdFailedToRefresh,
    this.onIsCollapsible,
    this.onAdImpression,
    this.onAdClicked,
    this.onAdOpened,
    this.onAdClosed,
  });

  /// Called when the banner successfully loads an ad.
  final void Function()? onAdLoaded;

  /// Called when the initial load fails.
  final void Function(AdError error)? onAdFailedToLoad;

  /// Called when the banner refreshes with a new ad.
  final void Function()? onAdRefreshed;

  /// Called when a refresh fails.
  final void Function(AdError error)? onAdFailedToRefresh;

  /// Called after load with whether the loaded ad is collapsible.
  final void Function(bool isCollapsible)? onIsCollapsible;

  /// Called when an impression is recorded.
  final void Function()? onAdImpression;

  /// Called when the banner is clicked.
  final void Function()? onAdClicked;

  /// Called when the banner opens an overlay covering the screen.
  final void Function()? onAdOpened;

  /// Called when a previously opened overlay is dismissed.
  final void Function()? onAdClosed;
}
