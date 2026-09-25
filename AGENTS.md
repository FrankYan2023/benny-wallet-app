# Benny Wallet repository handoff

Work in the existing Flutter app, `apps/wallet_client_flutter`; shared packages are in `packages/`.

For Arc/multichain work, read these first:
1. `docs/arc/AI_HANDOFF.md`
2. `docs/arc/CHANGELOG.md`
3. `MILESTONE_2_ARC.md`
4. `docs/arc/TEST_PLAN.md` and `docs/arc/VALIDATION.md`

Preserve existing Solana derivation, encrypted wallet records, custody modes and child-mode restrictions. Never derive EVM keys from Solana private keys. Inspect actual code before assuming a storage migration is needed. Keep chain protocol logic in adapters/services; UI uses shared network configuration.

Before changing Arc constants, recheck current official Arc/Circle docs. Testnet configuration is not production readiness. Backend API inventory here is inferred from client calls, not verification of server implementation. This repository has no backend source.

For future changes, append a dated entry to `docs/arc/CHANGELOG.md` (why, behavior, files, validation, remaining work), update affected test cases and the latest validation record. Keep prior results with their code revision; never silently promote pending tests to passed. Refresh the automated-test inventory when adding/removing tests. Use repository-relative documentation links so GitHub and a fresh checkout can read them.

Use disposable unfunded test wallets for smoke tests. Never commit real wallet phrases, private keys, PIN exports, credentials, local environment files or device secure-storage dumps. Public standard cryptographic test vectors are explicitly marked fixtures. Do not fund the disposable emulator wallet. Testnet funded acceptance uses separate private test-only wallets.
