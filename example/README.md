# Example — admob_flutter_plus

Demonstrates every ad format supported by `admob_flutter_plus` on Android:
banner, interstitial, rewarded / rewarded interstitial, native (built-in +
custom asset XML), and app open — plus UMP consent and Ad Inspector.

## Run

```bash
cd example
flutter pub get
flutter run
```

Use a physical Android device or emulator with Google Play services. The demo
uses Google test ad unit IDs by default (see `lib/ad_demo_constants.dart`).

## Notes

- Mounts one section at a time (not `TabBarView`) so PlatformViews dispose
  cleanly between formats.
- Native → **Custom** loads `assets/native/custom_native_ad.xml`.
