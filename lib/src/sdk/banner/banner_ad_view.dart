import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../core/ad_error.dart';
import '../core/ad_request.dart';
import 'ad_size.dart';
import 'banner_ad_controller.dart';
import 'banner_ad_listener.dart';

/// Native view type registered by the plugin for banner ads.
const String _bannerViewType = 'admob_flutter_plus/banner_ad';

/// A widget that displays a banner ad using an Android `AdView` PlatformView.
///
/// The widget requires a bounded height. Provide an explicit [height], or wrap
/// it in a `SizedBox`/`AspectRatio`. Adaptive banners resolve their own height
/// natively; the [height] you provide is the reserved slot in the Flutter
/// layout (collapsed size for collapsible banners).
///
/// On Android this uses Hybrid Composition (`initSurfaceAndroidView`) so
/// collapsible expand overlays are not trapped inside a Virtual Display texture.
///
/// On non-Android platforms this widget renders [placeholder] (or an empty box).
class BannerAdView extends StatefulWidget {
  /// Creates a [BannerAdView].
  const BannerAdView({
    super.key,
    required this.adUnitId,
    required this.size,
    this.height,
    this.request = const AdRequest(),
    this.listener,
    this.controller,
    this.placeholder,
  });

  /// The AdMob ad unit ID.
  final String adUnitId;

  /// The requested [AdSize].
  final AdSize size;

  /// Reserved height in dp. Required for adaptive sizes; for fixed sizes it
  /// defaults to the size's own height.
  final double? height;

  /// Per-request targeting and extras (for example collapsible configuration).
  final AdRequest request;

  /// Lifecycle callbacks.
  final BannerAdListener? listener;

  /// Optional controller for manual [BannerAdController.refresh].
  final BannerAdController? controller;

  /// Widget shown when the ad fails to load, or on unsupported platforms.
  final Widget? placeholder;

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  MethodChannel? _channel;
  bool _failed = false;

  double get _resolvedHeight {
    if (widget.height != null) return widget.height!;
    if (!widget.size.isAdaptive && widget.size.height != null) {
      return widget.size.height!.toDouble();
    }
    // Reasonable default reserved slot for anchored adaptive banners.
    return 100;
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  Map<String, dynamic> get _creationParams => <String, dynamic>{
        'adUnitId': widget.adUnitId,
        'size': widget.size.toMap(),
        'request': widget.request.toMap(),
      };

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('admob_flutter_plus/banner_ad_$id');
    _channel = channel;
    channel.setMethodCallHandler(_handleEvent);
    widget.controller?.attach(_refresh);
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _failed = false);
    try {
      await _channel?.invokeMethod<void>('refresh', _creationParams);
    } on PlatformException catch (e) {
      debugPrint('admob_flutter_plus: banner refresh failed: ${e.message}');
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<dynamic> _handleEvent(MethodCall call) async {
    if (!mounted) return null;
    final listener = widget.listener;
    final args = call.arguments;
    switch (call.method) {
      case 'onAdLoaded':
        if (_failed) setState(() => _failed = false);
        final map = _asMap(args);
        final resolved = map['adUnitId'] as String?;
        if (resolved != null && resolved.isNotEmpty) {
          widget.controller?.adUnitId = resolved;
        }
        listener?.onAdLoaded?.call();
        break;
      case 'onAdFailedToLoad':
        final error = AdError.fromMap(_asMap(args));
        setState(() => _failed = true);
        listener?.onAdFailedToLoad?.call(error);
        break;
      case 'onAdRefreshed':
        listener?.onAdRefreshed?.call();
        break;
      case 'onAdFailedToRefresh':
        final error = AdError.fromMap(_asMap(args));
        listener?.onAdFailedToRefresh?.call(error);
        break;
      case 'onIsCollapsible':
        final value = _asMap(args)['isCollapsible'] as bool? ?? false;
        listener?.onIsCollapsible?.call(value);
        break;
      case 'onAdImpression':
        listener?.onAdImpression?.call();
        break;
      case 'onAdClicked':
        listener?.onAdClicked?.call();
        break;
      case 'onAdOpened':
        listener?.onAdOpened?.call();
        break;
      case 'onAdClosed':
        listener?.onAdClosed?.call();
        break;
    }
    return null;
  }

  Map<dynamic, dynamic> _asMap(dynamic args) =>
      args is Map ? args : const <dynamic, dynamic>{};

  Widget _buildAndroidPlatformView() {
    // Prefer Hybrid Composition (same path as google_mobile_ads). Virtual
    // Display textures clip collapsible overlays to the reserved height even
    // when isCollapsible is true.
    return PlatformViewLink(
      viewType: _bannerViewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: _bannerViewType,
          layoutDirection: TextDirection.ltr,
          creationParams: _creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        );
        controller
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
          ..create();
        return controller;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    if (_failed && widget.placeholder != null) {
      return SizedBox(height: _resolvedHeight, child: widget.placeholder);
    }

    return SizedBox(
      height: _resolvedHeight,
      width: double.infinity,
      child: _buildAndroidPlatformView(),
    );
  }
}
