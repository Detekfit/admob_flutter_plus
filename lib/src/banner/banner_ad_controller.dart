/// Controls a [BannerAdView], enabling a manual [refresh] without recreating
/// the PlatformView.
///
/// Attach a controller to a [BannerAdView] via its `controller` parameter. A
/// controller may only be attached to a single view at a time.
class BannerAdController {
  /// Creates a [BannerAdController].
  BannerAdController();

  Future<void> Function()? _refreshImpl;

  /// Ad unit ID reported by the native SDK after the banner loads.
  ///
  /// `null` until the first successful load.
  String? adUnitId;

  /// Internal: wires the controller to a mounted [BannerAdView].
  void attach(Future<void> Function() refreshImpl) {
    _refreshImpl = refreshImpl;
  }

  /// Internal: detaches the controller when the view is disposed.
  void detach() {
    _refreshImpl = null;
    adUnitId = null;
  }

  /// Whether the controller is currently attached to a mounted view.
  bool get isAttached => _refreshImpl != null;

  /// Requests the attached banner to load again without recreating its
  /// PlatformView. No-op if not attached.
  Future<void> refresh() async {
    await _refreshImpl?.call();
  }

  /// Requests the attached banner to load again without recreating its
  /// PlatformView.
  ///
  /// Deprecated: use [refresh] instead.
  @Deprecated('Use refresh() instead')
  Future<void> reload() => refresh();
}
