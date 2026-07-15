/// Google-provided test ad unit IDs.
///
/// These always return test ads and are safe to ship in this example. Replace
/// them with your own ad unit IDs in a real app, and never click your own live
/// ads.
class AdDemoIds {
  const AdDemoIds._();

  /// Sample application ID (declared in `AndroidManifest.xml`).
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';

  static const String banner = 'ca-app-pub-3940256099942544/9214589741';
  static const String interstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String rewardedInterstitial =
      'ca-app-pub-3940256099942544/5354046379';
  static const String appOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String nativeAd = 'ca-app-pub-3940256099942544/2247696110';

  /// Deliberately invalid unit used to demonstrate load-failure handling.
  static const String invalidBanner = 'ca-app-pub-0000000000000000/0000000000';
}
