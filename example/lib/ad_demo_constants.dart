/// Google-provided test ad unit IDs.
///
/// These always return test ads and are safe to ship in this example. Replace
/// them with your own ad unit IDs in a real app, and never click your own live
/// ads.
class AdDemoIds {
  const AdDemoIds._();

  /// Sample application ID (declared in `AndroidManifest.xml`).
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';

  static const String anchoredAdaptiveBanner = 'ca-app-pub-3940256099942544/2014213617';
  static const String inlineAdaptiveBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const String fixedSizeBanner = 'ca-app-pub-3940256099942544/6300978111';

  static const String interstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedInterstitial = 'ca-app-pub-3940256099942544/5354046379';
  static const String appOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String nativeAd = 'ca-app-pub-3940256099942544/2247696110';

  /// Deliberately invalid unit used to demonstrate load-failure handling.
  static const String invalidAdUnit = 'ca-app-pub-0000000000000000/0000000000';

  /// Returns [invalidAdUnit] when [useInvalidUnit] is true, otherwise [valid].
  static String resolve(String valid, {required bool useInvalidUnit}) => useInvalidUnit ? invalidAdUnit : valid;
}

/// Shared demo options (edited via the AppBar bottom sheet).
class AdDemoConfig {
  const AdDemoConfig({this.useInvalidUnit = false});

  /// When true, every demo section requests [AdDemoIds.invalidAdUnit].
  final bool useInvalidUnit;

  AdDemoConfig copyWith({bool? useInvalidUnit}) {
    return AdDemoConfig(useInvalidUnit: useInvalidUnit ?? this.useInvalidUnit);
  }

  @override
  bool operator ==(Object other) => other is AdDemoConfig && other.useInvalidUnit == useInvalidUnit;

  @override
  int get hashCode => useInvalidUnit.hashCode;

  @override
  String toString() => 'AdDemoConfig(useInvalidUnit: $useInvalidUnit)';
}
