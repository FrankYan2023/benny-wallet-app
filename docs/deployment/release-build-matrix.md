# Release Build Matrix

This document defines how Benny Wallet release artifacts are versioned and how
Lite, Full, and Lite Seeker builds should differ.

## Version Rule

Every public artifact produced from the same release commit must use the same
app version.

- Flutter source of truth: `apps/wallet_client_flutter/pubspec.yaml`
- Android uses Flutter `version` as `versionName` and build number as
  `versionCode`
- iOS uses Flutter `version` as `CFBundleShortVersionString` and build number
  as `CFBundleVersion`

For example, `0.0.35+35` produces version name `0.0.35` and build number/code
`35` for all artifacts in that release.

## Artifact Matrix

### Android

Each Android release should publish three artifacts with the same version number:

| Artifact | Package | Feature profile | Notes |
| --- | --- | --- | --- |
| Full | `com.benny.wallet` | Full | Swap and xStocks enabled. |
| Lite | `com.benny.wallet.lite` | Lite | Swap and xStocks disabled. |
| Lite Seeker | `com.benny.wallet.lite.seeker` by default | Lite | Same Lite feature flags; Seeker/Seed Vault support remains enabled and runtime-gated by device support. |

The only intended product feature difference between Lite and Full is:

- Lite disables swap.
- Lite disables xStocks/stock token exchange entry points.
- All other business features and backend configuration should match Full,
  unless a platform/store policy explicitly requires a temporary override.

Current Android Gradle flavors in the project:

- `full`
- `liteStore`
- `liteSeeker`

The Lite Seeker flavor defaults to `com.benny.wallet.lite.seeker`. Override it
with `BENNY_LITE_SEEKER_APPLICATION_ID` or `LITE_SEEKER_APPLICATION_ID` in
`android/local.properties` only if the release channel uses a different package
id. It must still use the same Flutter version and the same Lite feature flags.

### iOS

iOS should match the Android business feature profiles:

| Artifact | Bundle id | Feature profile | Notes |
| --- | --- | --- | --- |
| Full | release Full bundle id | Full | Swap and xStocks enabled. |
| Lite | release Lite bundle id | Lite | Swap and xStocks disabled. |

Platform-specific integrations still follow platform capability:

- Seed Vault is Android/Seeker-specific and should remain runtime-gated.
- iOS push notifications must use iOS Firebase app configuration.

## Feature Flags

Full builds:

```text
STORE_MODE=full
FEATURE_SWAP_ENABLED=true
FEATURE_SWAP_XSTOCK_ENABLED=true
FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=true
```

Android Full builds must also keep the external update check enabled:

```text
FEATURE_APP_UPDATES_ENABLED=true
```

Lite and Lite Seeker builds:

```text
STORE_MODE=lite
FEATURE_SWAP_ENABLED=false
FEATURE_SWAP_XSTOCK_ENABLED=false
FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false
```

Keep these values identical across Android and iOS for the same feature profile.

## Firebase And Receive Notifications

Receive-transfer notifications depend on Firebase Cloud Messaging plus backend
device registration. The Firebase values must match the installed package/bundle.

Do not reuse a Firebase app id across platforms.

| Platform | Required Firebase app | Used by |
| --- | --- | --- |
| Android Full | Android Firebase app for `com.benny.wallet` | Full Android artifact |
| Android Lite | Android Firebase app for `com.benny.wallet.lite` | Lite Android artifact |
| Android Lite Seeker | Android Firebase app for the Lite Seeker package id | Lite Seeker Android artifact |
| iOS Full | iOS Firebase app for the Full bundle id | Full iOS artifact |
| iOS Lite | iOS Firebase app for the Lite bundle id | Lite iOS artifact |

The following values are platform/package specific and should come from the
matching release environment file or CI secrets:

```text
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET
FIREBASE_IOS_BUNDLE_ID   # iOS only
```

Important checks before publishing:

- Android `FIREBASE_APP_ID` should be an Android app id for the exact package.
- iOS `FIREBASE_APP_ID` should be an iOS app id for the exact bundle.
- Lite Seeker must include a valid Android Firebase configuration. It is not
  allowed to omit receive-transfer notifications.
- Wallets imported from Seeker Seed Vault must register for receive-transfer
  notifications after import, just like locally imported wallets.
- The installed app must request and receive notification permission.
- The app must register the FCM token with `/v1/notifications/register-device`
  after the wallet is unlocked and backend auth is available.

## Suggested Release Environment Files

Keep separate environment files or CI secret groups for each artifact:

```text
.env.release.android.full
.env.release.android.lite
.env.release.android.lite-seeker
.env.release.ios.full
.env.release.ios.lite
```

Each file should contain the same API/RPC values for the release environment,
and only differ where the package/bundle-specific Firebase configuration differs.

## Android Build Commands

Run from `apps/wallet_client_flutter`.

Full:

```bash
flutter build appbundle --flavor full --release \
  --dart-define-from-file=.env.release.android.full \
  --dart-define=STORE_MODE=full \
  --dart-define=FEATURE_SWAP_ENABLED=true \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=true \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=true \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=true
```

Lite:

```bash
flutter build appbundle --flavor liteStore --release \
  --dart-define-from-file=.env.release.android.lite \
  --dart-define=STORE_MODE=lite \
  --dart-define=FEATURE_SWAP_ENABLED=false \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=false \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false
```

Lite Seeker:

```bash
flutter build appbundle --flavor liteSeeker --release \
  --dart-define-from-file=.env.release.android.lite-seeker \
  --dart-define=STORE_MODE=lite \
  --dart-define=FEATURE_SWAP_ENABLED=false \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=false \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false
```

Use `flutter build apk` instead of `appbundle` only for internal/manual install
testing.

## iOS Build Commands

Run from `apps/wallet_client_flutter`.

Full:

```bash
flutter build ipa --release \
  --dart-define-from-file=.env.release.ios.full \
  --dart-define=STORE_MODE=full \
  --dart-define=FEATURE_SWAP_ENABLED=true \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=true \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=true
```

Lite:

```bash
flutter build ipa --release \
  --dart-define-from-file=.env.release.ios.lite \
  --dart-define=STORE_MODE=lite \
  --dart-define=FEATURE_SWAP_ENABLED=false \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=false \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false
```

If iOS Full and Lite use separate bundle ids, select the matching Xcode
configuration/scheme or update `PRODUCT_BUNDLE_IDENTIFIER` before building.

## Release Checklist

Before publishing a release:

1. Update `apps/wallet_client_flutter/pubspec.yaml` once.
2. Build every artifact from the same commit.
3. Confirm all Android artifacts report the same `versionName` and
   `versionCode`.
4. Confirm all iOS artifacts report the same marketing version and build
   number.
5. Confirm Lite and Lite Seeker have swap/xStocks disabled.
6. Confirm Full has swap/xStocks enabled.
7. Confirm Android Full shows and can run `Check for updates`.
8. Confirm Firebase app ids match each artifact package/bundle.
9. Smoke test receive-transfer notification registration on Android and iOS.
