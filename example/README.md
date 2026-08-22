# Example — admob_flutter_plus

Demonstrates every ad format supported by `admob_flutter_plus` on Android:
banner, interstitial, rewarded / rewarded interstitial, native (built-in +
custom asset XML), app open, and picture-in-picture (open beta) — plus UMP
consent and Ad Inspector.

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
- Native → **Custom** loads `assets/native/native_ad.xml` (or your asset XML).
- Mediation is optional. Do **not** add `gma_mediation_*` / `google_mobile_ads`.
  To try a Next-Gen adapter locally, uncomment the mediation block in
  `android/app/build.gradle.kts` (adapter deps + legacy `play-services-ads`
  excludes). See the package README → Mediation.
