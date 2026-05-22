# Android QA Integration Tests

This directory contains release-oriented Android emulator QA flows for Benny Wallet.

## Scope

- Import the configured QA wallet from mnemonic.
- Set the QA PIN.
- Verify the main portfolio screen opens.
- Verify Receive and Received history screens open.
- Verify Send history opens.
- Send the configured BYC amount to the configured recipient address.
- Swap the configured token amount in the Full flavor.

The test reads secrets and addresses from dart defines. Do not hard-code mnemonics or commit local `.env` files.

## Local Run

Prepare the ignored local env files first:

- `.env.config.lite.local`
- `.env.config.qa.local`

Then run:

```bash
set -a
source .env.config.lite.local
set +a

flutter test integration_test/android_qa/android_qa_wallet_flow_test.dart \
  -d <android-device-id> \
  --flavor full \
  --dart-define=STORE_MODE=full \
  --dart-define=FEATURE_WEBVIEW_ENABLED=true \
  --dart-define=FEATURE_SWAP_ENABLED=true \
  --dart-define=FEATURE_SWAP_XSTOCK_ENABLED=true \
  --dart-define=FEATURE_SWAP_TOKEN_EXCHANGE_ENABLED=true \
  --dart-define=FEATURE_AIRDROP_ENABLED=true \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=SOLANA_RPC_URL="$SOLANA_RPC_URL" \
  --dart-define-from-file=.env.config.qa.local \
  --dart-define=ANDROID_QA_SWAP_TOKEN_SYMBOL="${ANDROID_QA_SWAP_TOKEN_SYMBOL:-SOL}" \
  --dart-define=ANDROID_QA_SWAP_AMOUNT="${ANDROID_QA_SWAP_AMOUNT:-0.0001}"
```
