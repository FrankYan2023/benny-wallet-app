# Milestone 2 — Arc Support / Multichain Foundation

Last updated: 2026-09-19. Base: `08cbed3` (`origin/main`, Release Android v0.0.50).
Branch: `codex/milestone-2-arc`.
Repository: `FrankYan2023/benny-wallet-app`.
App: `apps/wallet_client_flutter`.
Worktree: `/Users/frankyan/.codex/.chatgpt-projects/g-p-6a12b1dad62c819185730cad6f417095/worktrees/benny-wallet-app-arc`.

## Delivery status

The existing Flutter client now has a shared chain interface, Solana wrapper, generic EVM implementation, and an Arc Testnet wallet loop. The code covers independent EVM account derivation, a single USDC balance, custom ERC-20 import (including BENNY when configured), receive/QR, reviewed transfers, fee estimation, EIP-1559 signing/broadcast, and receipt/log activity.

**Full MVP acceptance is not yet claimed.** iOS compilation is blocked by this machine's unaccepted Xcode license. A funded end-to-end Testnet transfer and real iOS/Android secure-storage/biometric regression still require device testing. No production mnemonic, private key or funded wallet was accessed; no real transaction was broadcast. Mainnet access remains permissioned per the official documentation.

## Actual architecture discovered before changes

| Area | Existing implementation and implications |
| --- | --- |
| Creation/import | `features/auth/presentation/providers/wallet_controller.dart`, onboarding pages, and `SolanaWalletService` create/import BIP39 phrases and discover Solana derivation candidates. |
| Persistent local custody | `WalletRepository.saveWallet` encrypts the **mnemonic text**, storing ciphertext, nonce, salt, Solana public key, derivation and custody in `wallet_records_v1`. Neither a BIP39 seed nor a raw Solana private key is the persisted root for this custody type. |
| PIN encryption | `core/crypto/local_cipher.dart`: AES-256-GCM; PBKDF2-HMAC-SHA256, 120,000 iterations, 16-byte salt, 12-byte nonce; ciphertext includes the authentication tag. |
| Legacy record handling | Existing `readRecords()` converts separate legacy encrypted fields into the record list and deletes those separate keys. This pre-existing migration was not changed or extended. Missing derivation fields resolve to the legacy Solana path. |
| Unlocked session | `MnemonicEphemeralStore` holds mnemonic strings behind opaque tokens with the controller's renewable 10-minute TTL. Plaintext unlocked sessions are deliberately not persisted. New EVM providers require the existing active token; no new recovery data is written. |
| External custody | `mobileWalletAdapter` and `seedVault` records store public address, authorization metadata, and an encrypted PIN marker, **not a mnemonic**. EVM is unavailable for these records; the original Solana flows remain. |
| Secure storage | `flutter_secure_storage`; Android encrypted SharedPreferences/Keystore and iOS Keychain. Biometric mnemonic wrapping uses the `benny_wallet/biometric_session` method channel. |
| Native biometrics | iOS `SceneDelegate.swift` uses CryptoKit AES-GCM with a Keychain key; Android `MainActivity.kt` uses AES-GCM AndroidKeyStore. App `local_auth` prompts gate access. See existing security caveats below. |
| Account model | `WalletControllerState` identifies selected Solana address, custody, derivation and unlock token. Child mode is receive-only. No changes to this serialized root model. |
| Assets | Shared `TokenInfo` plus `AssetHolding` and freezed/json_serializable models are Solana-oriented (mint/token program). Existing backend portfolio pricing and token discovery remain in place. |
| RPC | `SolanaWalletService` retains RPC selection/authentication, key derivation, SPL/Token-2022 handling, fees, Sender submission, and confirmation. |
| Send | Existing choose/compose/confirm/execute routes use Solana DTOs. They preserve rent reservation, Sender priority/tip budgets and MWA/SeedVault signing. |
| Receive | Formerly the selected Solana public key; now a shared explicit network selector and adapter account address/QR. |
| Activity | Existing backend history/notifications/asset activity remain. The new normalized chain activity is served through adapters. |
| State/navigation | Riverpod 2.6 StateNotifier/providers; go_router 16 with unlock and child-mode guards. Additional network routes use the same guards. |
| Build/test | Dart ^3.8, Flutter project version 0.0.50+50; iOS minimum 15; Android liteStore/liteSeeker/full flavors, release signing required. Existing tests covered API, constants, amounts, settings and localization; Android integration QA scripts also exist. |

## Key derivation and migration findings

The original Solana behavior is unchanged:

- Legacy: `m/44'/501'`.
- Standard: `m/44'/501'/0'/0'`.
- Imported accounts: persisted `accountIndex`/`changeIndex` select the original hardened path; neither is reset.

For compatible local custody, the same BIP39 phrase independently derives a secp256k1 EVM key at **`m/44'/60'/0'/0/0`**. The EVM key is not derived from any Solana key. Before exposing that account, the provider verifies that the phrase still derives the selected persisted Solana address using its original path. Multiple Solana accounts imported from the same root therefore share this first EVM account; switching their Solana indices does not silently choose another EVM index.

No existing encrypted record is rewritten for Arc; seed/private key bytes are transient. The new metadata store writes only custom-token metadata and public transaction records under `multichain_v1_*`, scoped by network and address. It never writes mnemonic, seed, derived key or signed transaction bytes.

Regression tests decrypt an independently generated ciphertext fixture matching the shipped format and assert byte-for-byte storage preservation. Independent SLIP-0010 fixtures cover legacy, standard and custom Solana addresses. **These validate the repository's format, not every historical production release or a real customer's stored data.** No blanket claim of safe production migration is made.

For an external or future private-key-only wallet, retain its original Solana account and recovery material. Add EVM only through an independently supported external signer or an explicitly imported BIP39 root whose ownership is verified; never reinterpret a Solana private key. No such migration wizard is included.

## New architecture

`core/chains/chain_models.dart` contains ChainFamily, ChainConfig, ChainAccount, ChainAsset, ChainFeeEstimate, transfer/prepared/signed models, ChainActivity and status. Amounts use BigInt base units; strict conversion rejects excess precision instead of rounding a payment.

`ChainAdapter` exposes account/address, balances/assets, address validation, fee estimate, build/sign/broadcast, transaction/activity and message signing.

- `SolanaAdapter` wraps the existing service. Additive sign/broadcast wrappers preserve the backend Sender route. Original Solana send screens and external custody routes remain intact. The adapter checks rent/fee reserves, request identity, owner derivation and signed message consistency.
- `EvmAdapter` implements Ethereum JSON-RPC, ABI calls, chain-aware typed transactions, receipts and Transfer logs. Native-token aliases, decimal conversion, gas floor, explorer/RPC and finality behavior are configuration data. There are no Arc/Solana protocol branches in the new widgets.
- `EvmKeyService` uses `bip39` + `bip32`; `web3dart` handles secp256k1, Keccak, ABI, RLP and EIP-1559; `eth_sig_util` handles EIP-712 V4. Versions are locked. Package availability is not evidence of an independent security audit.
- `multichain_providers.dart` connects adapters to existing custody/session state and adds account/assets/token/activity providers.
- `ChainTransferController` owns the review/sign/submit boundary. Reviews expire after two minutes and are single-use; signing is serialized per network/account. Session/child-mode/owner checks occur before preparation, signing and submission. A computed EVM hash is persisted before broadcast so a lost response does not erase the transfer.
- `MultichainStore` serializes metadata writes to avoid concurrent token imports/status updates losing data.

Future EVM networks can supply ChainConfig and network-specific indexing/pricing metadata. Networks without Arc's deterministic finality wait for a finalized block rather than being marked final merely on receipt. Ordinary EVM native inbound history still needs an indexer or another appropriate history source; configuration alone cannot provide missing RPC history APIs.

## Arc configuration — official sources verified

Verified official docs on 2026-09-16; RPC parameters and system event reference rechecked 2026-09-19:

| Field | Default Testnet | Opt-in private Mainnet |
| --- | --- | --- |
| Chain ID | 5042002 (`0x4cef52`) | 5042 (`0x13b2`) |
| RPC | `https://rpc.testnet.arc.io` | `https://rpc.mainnet.arc.io` |
| Explorer | `https://explorer.testnet.arc.io` | `https://explorer.arc.io` |
| Namespace | `eip155:5042002` | `eip155:5042` |
| Fee accounting | USDC, 18 decimals | USDC, 18 decimals |

Mainnet requires permissioned access; it is not enabled by default. Source: [Arc RPC endpoints](https://docs.arc.io/arc/references/rpc-endpoints).

USDC contract on both networks: `0x3600000000000000000000000000000000000000`, ERC-20 decimals 6. Native and ERC-20 interfaces share one balance. User sends use ERC-20 `transfer`; fee checks retain native precision and reserve the transfer plus maximum gas cost from that balance. Imported USDC resolves to the existing asset. Source: [Arc wallet integration](https://docs.arc.io/integrate/wallets/add-arc-to-a-wallet), [contract addresses](https://docs.arc.io/arc/references/contract-addresses).

History uses native system emitter `0xfffffffffffffffffffffffffffffffffffffffe`, Transfer signature `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef`, 18-decimal amounts. It avoids double-counting the additional USDC ERC-20 event. Incoming and outgoing filters are separate, merged by hash/log index. Fees come from receipts, not logs. Source: [USDC system events](https://docs.arc.io/arc/references/usdc-system-events).

Fee estimation queries gasPrice/feeHistory, uses EIP-1559 limits, applies Arc's documented 20-Gwei floor and 20% gas-limit margin. UI shows USDC values. Arc receipt inclusion is final; a reverted receipt means failed with gas spent. Missing receipts or interrupted requests are not classified as failed. Sources: [gas and fees](https://docs.arc.io/arc/references/gas-and-fees), [transaction lifecycle](https://docs.arc.io/integrate/wallets/transaction-lifecycle).

Configuration lives in `arc_chain_config.dart`, with constructor/provider injection available for future runtime configuration. Build overrides:

- `ARC_TESTNET_RPC_URL`, `ARC_TESTNET_EXPLORER_URL`.
- `ARC_DISABLE_RPC_FALLBACK=true` disables the documented dRPC Testnet fallback.
- `ENABLE_ARC_MAINNET=true`, `ARC_MAINNET_RPC_URL`, `ARC_MAINNET_EXPLORER_URL` for provisioned private-mainnet builds.
- `ARC_BENNY_TOKEN_ADDRESS` optionally loads issuer-verified BENNY metadata on the configured network. No unverified BENNY address is hardcoded; users can import it manually.

These are configuration inputs, not a remotely managed configuration service. Provider credentials compiled into a mobile app are not secret; use suitable restricted endpoints/proxy authentication before private-mainnet distribution.

## UI and completed functionality

- Existing visual theme/navigation retained; one wallet contains multiple chain accounts.
- Home includes additional network assets independently of backend Solana portfolio loading/failure. Testnet funds are explicitly excluded from real portfolio totals. Existing Solana total/pricing is unchanged; Arc assets do not yet have a fiat-price feed.
- Receive switches network, full address and QR together, with explicit network warning. Unsupported custody shows an explanation instead of substituting an address.
- Send retains old Solana path and provides a shared network send page: exact amount, validated recipient, estimate, review of full recipient/token/network/fees, explicit confirmation, hash and activity.
- USDC and generic ERC-20 balance/import/send implemented. Token metadata is bounded and rejects control/bidi characters, unsupported decimals, non-contract addresses and malformed ABI results.
- Activity polls without overlapping refreshes. It scans the latest 1,000 blocks in configured chunks (100 blocks on public Arc Testnet) plus the last 100 locally recorded submissions. It displays pending/final/failed/unknown, exact amounts and receipt fees. Public submissions remain visible if RPC reads fail.
- EIP-191 and chain-domain-checked EIP-712 V4 signing services are implemented, with namespace preparation and transfer/approval/unlimited-approval decoding. Unknown actions require additional review. No dapp signing UI is exposed.
- No new Swap, Bridge, DApp browser or full WalletConnect flow.

## Security considerations and known limits

- HTTPS RPC endpoints are verified with eth_chainId; a mismatch fails closed before signing/broadcast. Broadcasts are not automatically retried after ambiguous responses. Signed envelopes are tied to their reviewed payload, sender, chain, nonce and maximum fees.
- Existing native biometric protection is not guaranteed to be cryptographically biometric-bound on both platforms: iOS key access uses `WhenUnlockedThisDeviceOnly`; Android configures authentication parameters but does not enable `setUserAuthenticationRequired(true)`. The existing local_auth app prompt remains the gate. This pre-existing issue was not silently migrated.
- PIN KDF/storage, biometric enroll/unenroll behavior, physical-device lifecycle and legacy production releases require dedicated security/device review. Dart strings and library internals cannot guarantee complete memory zeroization; best-effort seed/private-key byte clearing does not change that.
- A timed-out/rejected broadcast reserves its nonce in the in-memory adapter to avoid accidental conflicting resubmission. No replacement/cancel/speed-up UI exists; inspect activity/explorer before retrying.
- History is recent and bounded, not a full historical indexer; pre-Zero5 legacy Testnet events are not backfilled. Metadata/public activity can remain in device storage after a wallet is removed; no new secret material is retained.
- New feature copy supports English and Chinese, with English fallback for other locales. Full seven-locale localization and grouped cross-network asset/fiat totals remain follow-up product work.
- Standard native value transfers are supported by the adapter; ordinary user USDC sends intentionally choose the canonical ERC-20 path. Arbitrary payable contract/dapp UI is out of scope.

## Validation

Final results are recorded below after execution. Existing tests were retained.

- `flutter pub get`: passed; locked compatible shared Dart dependencies.
- Baseline `flutter analyze`: passed before changes; baseline 21 tests passed using the installed Command Line Tools SDK.
- Final `flutter analyze --no-pub`: **passed, no issues** (5.8 seconds).
- Final `flutter test --no-pub`: **68 tests passed** (including all 21 original tests). Coverage includes independent derivation/signature vectors; old ciphertext/no-rewrite; Solana adapter delegation/reserves/request integrity; USDC dedup/precision; ERC-20 ABI; gas floor and insufficient balance; wrong-chain/stale-nonce/tamper guards; lost responses and duplicate submission; receipts/log dedup; custody/child/session guards; metadata concurrency; receive network switching and explicit send review.
- Widget render inspection: 390×844 receive and send-review screenshots generated under `apps/wallet_client_flutter/build/milestone2_qa/`; inspected for layout and complete network/address/fee labels. These use public synthetic test fixtures, not a real wallet.
- Read-only live RPC smoke (`dart run tool/arc_read_smoke.dart`): passed 2026-09-19, chain 5042002, USDC decimals 6, gas price `0x5d21dba00`, block `0x3c0c504`, 5 system Transfer events. Broadcast count **0**. Primary endpoint was previously inaccessible from this environment; documented dRPC fallback worked.
- Android `flutter build apk --debug --flavor liteStore --no-pub`: **passed**, final rebuild 31.3 seconds; artifact `apps/wallet_client_flutter/build/app/outputs/flutter-apk/app-litestore-debug.apk`. No release signing credentials used.
- iOS `flutter build ios --debug --no-codesign --no-pub`: **blocked**, exit 69 when Xcode enumerates the project: Xcode license not accepted. Flutter also reports first-launch components/CocoaPods require attention. No claim of successful iOS compilation.

On this host `/usr/bin/git` and native test hooks otherwise select the uninitialized Xcode installation. Analysis/Android used `DEVELOPER_DIR=/Library/Developer/CommandLineTools`. Unit/widget tests additionally used a temporary `/tmp/benny-arc-tools/xcrun` wrapper that selects the installed Command Line Tools SDK because native build hooks drop DEVELOPER_DIR. No license was accepted, system setting changed, or repository build logic bypassed. On a normally initialized Xcode installation, use ordinary Flutter commands.

## Files changed

All implementation paths below are under `apps/wallet_client_flutter/`:

- `lib/core/chains/chain_models.dart`, `chain_adapter.dart`, `arc_chain_config.dart`, `solana_adapter.dart`.
- `lib/core/chains/evm/evm_adapter.dart`, `evm_key_service.dart`, `evm_rpc.dart`, `evm_signing_intent.dart`.
- `lib/features/multichain/data/chain_transfer_controller.dart`, `multichain_store.dart`.
- `lib/features/multichain/providers/multichain_providers.dart`.
- `lib/features/multichain/presentation/chain_widgets.dart`, `network_page.dart`, `network_send_page.dart`, `token_import_page.dart`.
- `lib/features/auth/data/solana_wallet_service.dart` (additive wrappers and exact fee-unit methods).
- `lib/features/portfolio/presentation/pages/portfolio_page.dart`, `lib/features/receive/presentation/pages/receive_page.dart`, `lib/features/send/presentation/pages/send_page.dart`, `lib/app/router.dart`.
- `pubspec.yaml`, `pubspec.lock`.
- `test/core/chains/evm_adapter_test.dart`, `evm_rpc_test.dart`, `solana_adapter_test.dart`.
- `test/features/auth/wallet_storage_regression_test.dart`.
- `test/features/multichain/chain_transfer_controller_test.dart`, `multichain_store_test.dart`, `widgets_test.dart`.
- `tool/arc_read_smoke.dart` (optional public read-only check).
- Repository root: `MILESTONE_2_ARC.md`.

No files in the synced project `sources/`, no backend repository, and no iOS/Android native security source were changed.

## Remaining acceptance and next step

1. Owner initializes Xcode/accepts its license; fix CocoaPods if still necessary, then run unsigned iOS build and simulator/device tests.
2. On fresh **private test-only** local mnemonics, verify existing Solana address and Arc address on both devices; exercise PIN, biometrics, lock/timeout, app restart, wallet switch, and external custody rejection for EVM. Never fund public test vectors.
3. Use faucet Testnet funds to receive/send USDC and issuer-verified BENNY/custom ERC-20; verify hash, recipient, fee and final receipt in the explorer; test insufficient gas/revert/offline response handling. This live funds flow has not been run.
4. Validate representative backed-up production record versions in a controlled recovery QA process before release. No production migration is required by this change.
5. Provision private-mainnet access and verify actual BENNY deployment before enabling mainnet. Perform a dedicated wallet security review before distributing a release build.

Recommended next step: complete the funded Android Testnet transfer/receipt checklist first, then initialize Xcode and finish iOS and physical-device validation. WalletConnect, swap, bridge and additional EVM networks remain separate later phases.


## Android emulator interaction pass (2026-09-22–24)

Device: dedicated `Benny_Arc_QA_API36`, Pixel 7, Android 16/API 36,
Google APIs ARM64, 1080×2400. The original app's `liteStore` flavor is used.
A random, unfunded QA mnemonic is encrypted using the existing Android secure
storage/PIN flow. No existing user wallet was opened, rewritten or migrated.
No transfer was signed or broadcast during this pass.

Fixes:
- Guard the PIN unlock continuation before calling `setState` or reading its
  provider after the router has disposed the page. The first real emulator
  test reproduced `setState() called after dispose`; subsequent runs passed.
- Receive history follows the selected network. Solana retains its original
  receipt feed; Arc opens its own network activity. Routing is centralized in
  `chain_navigation.dart` rather than adding protocol branches to widgets.
- Child mode hides the unsupported token import action, consistently with its
  existing route restrictions.
- Arc Testnet history now uses configurable 100-block log queries. Live public
  fallback requests rejected 250-block ranges with HTTP 400/provider code 35;
  100-block requests succeeded. The full 1,000-block window remains intact.
  Regression coverage checks contiguous incoming/outgoing coverage without gaps.

Validation:
- Dedicated emulator integration test: **passed**, final retained-wallet run 43 seconds after build,
  using actual app routing, Android secure storage and public Arc RPC reads.
  Covers PIN unlock, existing Solana address, derived Arc address/QR switching,
  clipboard feedback, Arc history navigation and successful empty-history loading,
  invalid recipient/zero amount,
  insufficient balance, USDC metadata lookup/import and balance deduplication.
- Unit/widget regression suite: **70 tests passed**, including all existing
  tests plus selected-network history and child-mode action checks.
- Static analysis: **passed**, no issues (8.5 seconds after the history fix).
- Regular Android debug APK: **built successfully**, final rebuild 16.0 seconds, and installed
  for manual inspection. Flutter test itself removes its harness and wallet;
  retained QA state requires flutter run followed by adb install -r.
- Existing localization generation still reports 310 untranslated Chinese
  messages; the repository's localization coverage test passes. Full translation
  is outside this interaction pass.

Additional changed files: `lib/features/auth/presentation/pages/unlock_page.dart`,
`lib/features/multichain/presentation/chain_navigation.dart`,
`lib/features/multichain/presentation/network_page.dart`,
`lib/features/receive/presentation/pages/receive_page.dart`,
`test/features/multichain/widgets_test.dart`, and
`integration_test/arc/{arc_emulator_smoke_test.dart,README.md}`,
`lib/core/chains/{chain_models.dart,arc_chain_config.dart}`,
`lib/core/chains/evm/evm_adapter.dart`, `test/core/chains/evm_adapter_test.dart`,
and `tool/arc_read_smoke.dart` (app-relative).

This completes the unfunded Android smoke path, not the funded cross-platform
MVP acceptance. iOS build setup, physical-device biometric checks, controlled
production-format recovery validation, and actual Testnet transfer/receipt
verification remain open. No mainnet readiness or safe production migration is
claimed.


Manual regular-APK checks on 2026-09-24:
- Retained QA harness completed its assertions, then a regular APK replaced it
  using `adb install -r`. Cold launch required PIN and unlocked the same QA root.
- Checked receive network/address/QR, network history navigation, recipient
  keyboard Next → numeric amount keyboard, Android Back hiding the keyboard
  without leaving the form, and inline insufficient-balance feedback.
- Inspected normal and 130% system-font send layouts; labels/actions remain
  visible and contract text wraps. Restored system font scale to 1.0.
- Read-only full-history smoke passed after the range fix: block `0x3ccc13b`,
  USDC decimals 6, six system events in that block, zero recent events for this
  unfunded QA account, zero broadcasts. The optional public-address argument to
  `tool/arc_read_smoke.dart` now exercises the same adapter history path as UI.
- Screenshots are generated locally under
  `apps/wallet_client_flutter/build/emulator_qa/`: `home.png`,
  `arc-receive.png`, `arc-send-keyboard.png`, `arc-amount-keyboard.png`,
  `arc-send-validation.png`, `arc-send-large-text.png`.

Final emulator rerun (2026-09-24) passed the added live history-loading assertion
and reused the marked QA wallet from the previous ordinary APK. The test runner
reported all tests passed before the emulator was subsequently closed.

The emulator was restarted and the final ordinary APK reinstalled afterward.
PIN unlock succeeded, and the Arc activity page loaded its empty state normally;
`build/emulator_qa/arc-activity.png` records this final manual verification.
The dedicated emulator was left running on that page.

## Unified two-network interface (2026-09-25)

The product layout now supersedes the earlier separate-network card:
- The balance card's upper-right selector defaults to **All networks** and can
  filter Solana or Arc. Existing Solana totals/pricing remain intact; Arc
  Testnet assets are shown but excluded from real dollar totals.
- Solana and Arc assets share the existing `TokenRow` design and explicit network
  labels. The standalone Arc module and empty-wallet “Receive SOL” panel are
  removed. An unfunded primary account shows its zero native balance as a row.
- The existing Send entry now contains a network selector. Arc's reusable form
  renders inside that page; the extra “Send on Arc” entry is removed. Switching
  networks discards the form state, and the selector is blocked during an
  in-flight operation. The original Solana compose/sign/broadcast flow stays in
  place with an explicit network label.
- Receive uses the existing shared network selector/address/QR screen. Asset
  detail actions retain the asset's network when entering Send or Receive.
- Arc assets open the existing asset-detail route and reuse its header/actions/
  balance components. The old network landing page now shows activity only;
  legacy network-send URLs redirect to the shared Send entry.
- Token import is reached from the shared Assets heading. No new key storage,
  signing algorithms, wallet migration or native platform changes were made.

Implementation touches the portfolio, send, receive navigation and asset-detail
presentation, router, shared TokenRow (optional network label), and tests.
`portfolio_network_widgets.dart` owns the shared filter/menu/asset rows.

Validation: static analysis passed; **72 unit/widget tests passed**;
Android emulator integration passed in 46 seconds, covering default two-chain
visibility, network filtering, receive address switching, history, shared Send
validation and token import deduplication. Ordinary Android APK rebuilt in
18.8 seconds in the final rebuild. No transfer was broadcast. iOS setup/funded transfer acceptance
remain the previously documented open items.


Manual UI review of the ordinary APK confirmed the selector in the balance
card's upper-right corner, default SOL/Arc USDC rows, Arc-only filtering,
inline Arc Send with the selected network visible, and asset-detail Receive
opening the correct Arc address. The empty SOL row now uses the asset name
without repeating the network name and has the same row spacing as other
assets. Arc-only filtering hides Swap because that network has no supported
swap integration; Solana/All retain the existing Solana action.
Screenshots: `build/emulator_qa/unified-home.png`,
`unified-network-menu.png`, `unified-send.png`, `unified-receive.png`
(app-relative). All 72 tests and analysis passed again after the final tweaks.
