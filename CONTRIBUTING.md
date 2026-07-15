# Contributing to admob_flutter_plus

Thanks for your interest in improving `admob_flutter_plus`! This is a
community-maintained, **unofficial** plugin. Contributions of all kinds are
welcome.

## Code of conduct

Be respectful and constructive. Assume good intent. Harassment of any kind is
not tolerated.

## Development setup

1. Install the Flutter SDK (`>=3.27.0`) and an Android toolchain.
2. `flutter pub get`
3. Open the example: `cd example && flutter run` on a physical Android device.

## Module map

The codebase is intentionally modular so contributors can work in isolation.
Each ad format has one Dart module and one Kotlin manager.

| Layer | Location |
|---|---|
| Dart public API | `lib/src/<format>/` |
| Kotlin managers | `android/src/main/kotlin/io/admobflutterplus/admob_flutter_plus/<format>/` |
| Shared Dart utilities | `lib/src/core/` |
| Shared Kotlin utilities | `android/.../core/`, `android/.../helper/` |

No cross-imports between format managers except through shared `core/`.

## Branch naming

- `feature/<short-name>` — new functionality
- `fix/<short-name>` — bug fixes
- `docs/<short-name>` — documentation only

## Pull request requirements

Every PR should:

- [ ] Pass `dart analyze` with zero issues.
- [ ] Pass `flutter test`.
- [ ] Update `CHANGELOG.md` (Keep a Changelog format).
- [ ] Update `README.md` if the public API changed.
- [ ] Add dartdoc comments on new public classes and members.

Conventional commit messages are encouraged (`feat:`, `fix:`, `docs:`, ...).

## Versioning policy

- **MAJOR** — breaking Dart API change, or a minimum SDK bump with a breaking
  native change.
- **MINOR** — new ad format, new optional parameters, or a new template.
- **PATCH** — bug fixes, docs, and native SDK patch bumps.

## How to bump the `ads-mobile-sdk` version safely

The Next-Gen SDK is evolving; builder method names and APIs change between
versions. To bump it:

1. Read the [release notes](https://developers.google.com/admob/android/next-gen/rel-notes)
   for every version between the current and target version.
2. Update the version in `android/build.gradle.kts`.
3. Re-verify the affected Kotlin call sites (especially `AdRequestExt.kt`,
   `NextGenBannerAdView.kt`, `PreloaderManager.kt`, and the fullscreen managers).
4. Run the example app on a **physical device** and exercise every ad type.
5. Update `CHANGELOG.md` and this file if the process changed.

## How to add a new ad format

1. Add a Dart module under `lib/src/<format>/` with the public ad class and
   listener, and export it from `lib/admob_flutter_plus.dart`.
2. Add a Kotlin manager under `android/.../<format>/`.
3. Add method routing cases in `AdmobFlutterPlusPlugin.kt`.
4. Add unit tests for any pure Dart logic.
5. Add a section to the example app.
6. Document it in the README and CHANGELOG.

## How to add a new banner size

1. Add an `AdSize` factory and an `AdSizeType` enum value in
   `lib/src/banner/ad_size.dart`.
2. Add a matching branch in `resolveAdSize()` in `NextGenBannerAdView.kt`.
3. Add a unit test in `test/ad_size_test.dart`.

## How to add a new native template

1. Add an XML layout in `android/src/main/res/layout/`.
2. Add a value to the `NativeTemplate` enum in `NextGenNativeAdView.kt` and
   register a factory in the plugin.
3. Add a Dart widget wrapper in `lib/src/native/native_ad_widgets.dart`.
