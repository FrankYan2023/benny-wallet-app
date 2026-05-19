# Android QA Integration Tests

This directory contains release-oriented Android emulator QA flows for Benny Wallet.

## Scope

- Import the configured QA wallet from mnemonic.
- Set the QA PIN.
- Verify the main portfolio screen opens.
- Verify Receive and Received history screens open.
- Verify Send history opens.
- Send the configured BYC amount to the configured recipient address.

The test reads secrets and addresses from dart defines. Do not hard-code mnemonics or commit local `.env` files.

## Local Run

Prepare the ignored local env files first:

- `.env.config.lite.local`
- `.env.config.qa.local`

Then run:

```bash
set -a
source .env.config.lite.local
source .env.config.qa.local
set +a

flutter test integration_test/android_qa/android_qa_wallet_flow_test.dart \
  -d <android-device-id> \
  --flavor liteStore \
  --dart-define=STORE_MODE=lite \
  --dart-define=FEATURE_WEBVIEW_ENABLED=false \
  --dart-define=FEATURE_SWAP_ENABLED=false \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=false \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=false \
  --dart-define=FEATURE_AIRDROP_ENABLED=true \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=SOLANA_RPC_URL="$SOLANA_RPC_URL" \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET" \
  --dart-define=ANDROID_QA_IMPORT_MNEMONIC="$ANDROID_QA_IMPORT_MNEMONIC" \
  --dart-define=ANDROID_QA_EXPECTED_WALLET_ADDRESS="$ANDROID_QA_EXPECTED_WALLET_ADDRESS" \
  --dart-define=ANDROID_QA_RECIPIENT_ADDRESS="$ANDROID_QA_RECIPIENT_ADDRESS" \
  --dart-define=ANDROID_QA_PIN="$ANDROID_QA_PIN" \
  --dart-define=ANDROID_QA_SEND_TOKEN_SYMBOL="$ANDROID_QA_SEND_TOKEN_SYMBOL" \
  --dart-define=ANDROID_QA_SEND_TOKEN_NAME="$ANDROID_QA_SEND_TOKEN_NAME" \
  --dart-define=ANDROID_QA_SEND_TOKEN_MINT="$ANDROID_QA_SEND_TOKEN_MINT" \
  --dart-define=ANDROID_QA_SEND_TOKEN_DECIMALS="$ANDROID_QA_SEND_TOKEN_DECIMALS" \
  --dart-define=ANDROID_QA_SEND_TOKEN_AMOUNT="$ANDROID_QA_SEND_TOKEN_AMOUNT"
```
