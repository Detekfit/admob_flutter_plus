# Publish guide — admob_flutter_plus

Customize the variables below, then run the commands in order.
Do **not** publish until `dry-run` reports **0 warnings** (or only warnings you accept).

## Customize

```bash
# --- edit these ---
PACKAGE_DIR="e:/Project/Flutter Package/admob_flutter_plus"   # repo root
VERSION="0.1.0"                                               # must match pubspec.yaml
PUBLISHER_EMAIL="YOUR_EMAIL@example.com"                      # pub.dev account
# --- end customize ---

cd "$PACKAGE_DIR"
```

PowerShell:

```powershell
# --- edit these ---
$PackageDir = "e:\Project\Flutter Package\admob_flutter_plus"
$Version    = "0.1.0"
# --- end customize ---

Set-Location $PackageDir
```

## 1. Preflight checks

```bash
flutter --version
dart --version

flutter pub get
dart analyze
flutter test
```

PowerShell (same):

```powershell
flutter pub get
dart analyze
flutter test
```

Expected: **No issues found** and **All tests passed**.

## 2. Clean git (recommended)

```bash
git status
git add -A
git commit -m "chore: release $VERSION"
git push origin HEAD
```

PowerShell:

```powershell
git status
git add -A
git commit -m "chore: release $Version"
git push origin HEAD
```

## 3. Dry-run publish

```bash
dart pub publish --dry-run
```

Confirm:

- Archive includes `lib/`, `android/`, `example/`, `LICENSE`, `README.md`, `CHANGELOG.md`
- **Does not** include `prompt.md` / `PUBLISH.md`
- Description ≤ 180 chars
- homepage / repository point at `https://github.com/Detekfit/admob_flutter_plus`

## 4. Login (once per machine)

```bash
dart pub login
```

Browser opens; sign in with the Google account that owns the pub.dev publisher.

## 5. Publish for real

```bash
dart pub publish
```

Type `y` when asked. Package URL after success:

`https://pub.dev/packages/admob_flutter_plus`

## 6. Post-publish checklist

- [ ] Open the pub.dev page and verify version `$VERSION`
- [ ] Verify README / changelog / screenshot render
- [ ] Tag the release (optional):

```bash
git tag "v$VERSION"
git push origin "v$VERSION"
```

## Rollback / yank (only if needed)

```bash
# Discouraged — prefer a new patch version instead
dart pub unpublish admob_flutter_plus:$VERSION
```

## Common fixes

| Issue | Fix |
|---|---|
| Description too long | Shorten `description` in `pubspec.yaml` (≤ 180) |
| Wrong GitHub URL | Update `homepage` / `repository` / `issue_tracker` |
| Dirty git warning | Commit or stash before publish |
| `prompt.md` in archive | Keep it listed in `.pubignore` |
| Not authorized | `dart pub login` with the correct account |
