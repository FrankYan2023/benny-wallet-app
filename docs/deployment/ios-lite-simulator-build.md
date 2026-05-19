# iOS Lite Simulator Build

This note documents how to build and launch the iOS simulator version with the
same Benny Wallet Lite business configuration used by the Android Lite package.
For the full release artifact matrix, see
[`release-build-matrix.md`](release-build-matrix.md).

## Purpose

Use this flow when validating iOS wallet creation/import flows locally. The
important part is to avoid the app's fallback API endpoint:

```text
https://api.example.invalid
```

If `API_BASE_URL` is not passed at build time, import-wallet scanning fails with
`Failed host lookup: 'api.example.invalid'`.

## Prerequisites

- Flutter stable installed.
- Xcode installed with a matching iOS Simulator runtime.
- CocoaPods specs are current enough for the Firebase pods.
- An iOS simulator is booted or available.

Useful setup commands:

```bash
cd /Volumes/Data/workspace/benny-wallet/benny-wallet-app/apps/wallet_client_flutter

flutter pub get
pod repo update
```

If Xcode reports `iOS <version> Platform Not Installed`, install the matching
simulator runtime:

```bash
xcodebuild -downloadPlatform iOS -architectureVariant arm64
```

## Simulator Support

The Runner target must support simulator builds:

```text
SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
```

Without this setting, Xcode may only list `Any iOS Device` and reject simulator
destinations.

## Build Command

This command aligns iOS with the Android Benny Wallet Lite feature/API
configuration while producing a debug simulator app. Lite means swap and xStocks
are disabled; all other business configuration should match Full:

```bash
cd /Volumes/Data/workspace/benny-wallet/benny-wallet-app/apps/wallet_client_flutter

flutter build ios --simulator --debug \
  --dart-define=STORE_MODE=lite \
  --dart-define=FEATURE_SWAP_ENABLED=false \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=false \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false \
  --dart-define=API_BASE_URL=https://api.gobennyapp.com \
  --dart-define=SOLANA_RPC_URL=https://api.gobennyapp.com/v1/solana-rpc
```

To target a specific simulator:

```bash
flutter devices

flutter build ios --simulator --debug -d <SIMULATOR_UDID> \
  --dart-define=STORE_MODE=lite \
  --dart-define=FEATURE_SWAP_ENABLED=false \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=false \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false \
  --dart-define=API_BASE_URL=https://api.gobennyapp.com \
  --dart-define=SOLANA_RPC_URL=https://api.gobennyapp.com/v1/solana-rpc
```

The simulator app is written to:

```text
build/ios/iphonesimulator/Runner.app
```

## Launch Locally

Install and launch with `simctl`:

```bash
xcrun simctl boot <SIMULATOR_UDID> || true
xcrun simctl install <SIMULATOR_UDID> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <SIMULATOR_UDID> com.benny.wallet.walletClientFlutter
```

## Firebase Notes

Do not pass an Android Firebase app id to iOS, and do not pass an iOS Firebase
app id to Android.

Android and iOS receive-transfer notifications use different Firebase app
records, even when they share the same Firebase project. Passing the wrong
platform `FIREBASE_APP_ID` can break Firebase initialization or FCM token
registration. On iOS, an invalid `GOOGLE_APP_ID` can crash Firebase Core with:

```text
Configuration fails. It may be caused by an invalid GOOGLE_APP_ID
```

For this simulator validation flow, omit Firebase `--dart-define` values unless
an iOS Firebase app has been created and its iOS-specific values are available.
The app can still validate wallet import and API connectivity without Firebase,
but receive-transfer notifications require the correct iOS Firebase config.

## API Verification

Before testing import-wallet flows, verify the production API is reachable:

```bash
curl -sS -m 10 \
  -X POST https://api.gobennyapp.com/v1/import-wallet/scan \
  -H 'content-type: application/json' \
  --data '{"addresses":[],"fallbackAddresses":[]}'
```

Expected result is a business validation error such as:

```json
{"error":"InvalidRequest","message":"addresses must contain 1 to 32 candidate wallet addresses."}
```

This confirms the build should not fail with `api.example.invalid`.
