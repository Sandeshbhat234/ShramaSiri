# Android build

## Toolchain

| Tool | Version used and verified |
|---|---|
| Flutter | 3.47.7 (stable), Dart 3.13.5 |
| Android Gradle Plugin / Gradle / Kotlin | 9.1.0 / 9.3.1 / 2.4.0 (Flutter template defaults) |
| JDK | 17 (Temurin) |
| Android SDK | compile/target SDK 36, min SDK 24 (Android 7.0) |
| NDK | 28.2.13676358 (Flutter default) |

Point `JAVA_HOME` at a JDK 17+ before building, e.g. on Windows PowerShell:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17...'
```

## Configuration

The Supabase URL and publishable key are compiled in with
`--dart-define-from-file`:

```bash
cp .env.example .env        # fill in SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY
```

A build without them shows a "Server not configured" screen.

## Signing (release)

1. Create a keystore once and keep it (and its passwords) safe; losing it
   means you cannot publish updates:
   ```bash
   keytool -genkey -v -keystore shramasiri-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias shramasiri
   ```
2. Create `android/key.properties` (git-ignored):
   ```
   storeFile=C:/path/to/shramasiri-release.jks
   storePassword=...
   keyAlias=shramasiri
   keyPassword=...
   ```
Without `key.properties` the release build is signed with the debug key —
fine for testing, never for distribution.

## Builds

```bash
flutter pub get
dart run build_runner build      # Drift (only needed after changing tables)
flutter gen-l10n                 # after changing lib/l10n/*.arb

# Sideloading to family phones: one APK per CPU type (most phones: arm64-v8a)
flutter build apk --release --split-per-abi --dart-define-from-file=.env

# Google Play
flutter build appbundle --release --dart-define-from-file=.env
```

Outputs: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` and
`build/app/outputs/bundle/release/app-release.aab`.

Measured sizes (release, per ABI): arm64-v8a ≈ 23 MB installed APK, of which
the Flutter engine is 11.8 MB and app code 9.6 MB, stored uncompressed as
required for modern Android; the Play Store download is roughly half of that.

## Installing on a family phone

```bash
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```
or copy the APK to the phone and open it (allow "install unknown apps" for the
file manager once).

## Known build notes (Windows)

- **Kotlin incremental compilation** fails with "Could not close incremental
  caches" when the project and the pub cache are on different drives.
  `android/gradle.properties` sets `kotlin.incremental=false`.
- **`flutter build appbundle` may report "failed to strip debug symbols"**.
  This comes from the `jni` native library pulled in by
  `path_provider_android`. The bundle is still written; the libraries
  delivered to phones are stripped (debug symbols are kept separately under
  `BUNDLE-METADATA` for Play crash reports). Verified by inspecting the AAB.
- Paths containing spaces work, but keep the project path short if you hit
  path-length limits.

## Emulator tips

- Debug builds can reach a local Supabase stack at `http://10.0.2.2:55421`
  (cleartext allowed only in debug).
- A freshly booted emulator may be slow and show "System UI isn't responding";
  that is the emulator, not the app. Give it 4 GB RAM if possible.
- If an AVD has a screen lock PIN, apps cannot start until it is unlocked.
