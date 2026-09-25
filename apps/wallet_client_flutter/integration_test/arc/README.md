# Arc Android emulator smoke test

Run on a **dedicated disposable emulator**, never a personal wallet device:

```sh
flutter test integration_test/arc/arc_emulator_smoke_test.dart \
  -d emulator-5554 --flavor liteStore \
  --dart-define=BENNY_EMULATOR_QA=true \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false
```

The opt-in test creates a random, unfunded QA wallet in real Android secure
storage. Flutter test uninstalls its harness after completion, so that command
does not preserve the QA wallet between runs. A retained debug harness refuses
unmarked existing wallets on rerun. The test PIN is `258025`. It refuses
existing wallets unless their public root matches its QA marker. The marker
is an accidental-use guard, not a security boundary. Do not fund this wallet
or use the test PIN for a real wallet. No recovery phrase is logged/exported.

The test launches the actual app, unlocks using the PIN keypad, checks the
default unified portfolio, action order, bundled network badges and each network filter, then switches from
Solana to Arc receive, checks the derived address and clipboard feedback,
opens the selected network's history and waits for successful loading, validates invalid/zero/insufficient
send inputs through the shared Send entry, looks up USDC metadata from the real RPC, imports it and checks
that only one USDC asset row remains. It never signs or broadcasts a transfer.
Live RPC availability is required. The existing Android send/swap QA suite is
separate and is not invoked by this command.

Validated on 2026-09-22–25 using `Benny_Arc_QA_API36` (Pixel 7, Android 16/API 36,
Google APIs ARM64). On this development host, Flutter commands require
`DEVELOPER_DIR=/Library/Developer/CommandLineTools` until Xcode is initialized.

After the test, install a regular `flutter build apk --debug --flavor liteStore`
build for manual UX inspection; the integration APK contains the test harness.
To retain QA state for manual inspection, use `flutter run -t
integration_test/arc/arc_emulator_smoke_test.dart` with the same flavor/defines,
wait for its assertions to pass, detach with `d`, then install the regular APK
with `adb install -r`. That workflow preserves the disposable test wallet. Clearing app data
is only appropriate for this disposable QA device, never an existing wallet.

## Feature-mode coverage

Run the same unfunded smoke in both configurations (the Android flavor and
Dart feature mode are independent):

- `--flavor full --dart-define=STORE_MODE=full`: Send, Receive, Swap in order.
- `--flavor liteStore --dart-define=STORE_MODE=lite`: Send, Receive; Swap hidden.

Retain all safety flags shown above. Both configurations assert that Arc-only
filtering hides Swap, and that Solana/Arc badges use the bundled network assets.
The public-RPC read checks and no-sign/no-broadcast restriction are identical.
The flavor package IDs differ, so the dedicated emulator keeps independent QA
wallet state for full and liteStore. Never copy recovery material between them.
