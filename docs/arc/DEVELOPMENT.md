# 开发、构建与复测

## 环境与目录

以下命令从仓库根目录进入 `apps/wallet_client_flutter` 执行。验证机使用 Flutter 3.41.6 / Dart 3.11.4 / macOS，Android Pixel 7 API 36 ARM64 专用模拟器。Dart最低版本与依赖看 `pubspec.yaml` / `pubspec.lock`。本仓库尚无 GitHub Actions 配置，GitHub分支存在不代表CI已经运行。

```sh
cd apps/wallet_client_flutter
flutter pub get
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

本地主机如 Xcode 未初始化，Android/分析可临时使用 `DEVELOPER_DIR=/Library/Developer/CommandLineTools`。此前本地 native test hooks 还需一个临时 xcrun wrapper 选择已安装 Command Line Tools；它不在仓库，也不是新机器依赖。正常环境应初始化 Xcode 后使用普通命令，不能通过文档假定 Xcode许可已接受。

## Android

```sh
flutter devices
flutter build apk --debug --flavor liteStore --no-pub \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false
flutter run --flavor liteStore -d <device-id> \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false
```

输出 `build/app/outputs/flutter-apk/app-litestore-debug.apk`。用 `adb -s <device-id> install -r <apk>` 原地更新专用 QA 设备，避免卸载/清数据丢掉测试状态。不要对个人设备运行清除钱包数据的命令。

Android flavor 为 `liteStore` / `liteSeeker` / `full`；`STORE_MODE` 和 `FEATURE_*` 是独立的 Dart 配置。当前默认 `STORE_MODE=full`，所以 liteStore debug 仍可能看到 Swap。真正Lite产品测试要显式传 `--dart-define=STORE_MODE=lite`。其他 flavor、签名 release、商店提审尚需单独验证；不要拿一次debug构建代替它们。

## iOS

在已初始化 Xcode、CocoaPods、iOS SDK 的 Mac 上：

```sh
flutter build ios --debug --no-codesign --no-pub
flutter devices
flutter run -d <ios-simulator-or-device-id>
```

本轮历史检查因 Xcode许可未接受而阻塞；无成功的iOS构建记录。物理设备生物识别/Keychain与签名分发是额外验收，不由无签名构建涵盖。

## Arc 配置

默认值与 source links 见 [`arc_chain_config.dart`](../../apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart) 和 [架构记录](../../MILESTONE_2_ARC.md)。当前默认 Testnet 5042002。参数由 `--dart-define=NAME=value` 传入：

| 参数 | 用途 |
| --- | --- |
| `ARC_TESTNET_RPC_URL` / `ARC_TESTNET_EXPLORER_URL` | 替换测试网端点 |
| `ARC_DISABLE_RPC_FALLBACK=true` | 关闭公共dRPC备用端点 |
| `ARC_BENNY_TOKEN_ADDRESS` | 经发行方核实的当前网络BENNY合约；未配置可手工导入 |
| `ENABLE_ARC_MAINNET=true` | 启用预留主网配置；不是普通QA指令，先重新核对官方文档/接入 |
| `ARC_MAINNET_RPC_URL` / `ARC_MAINNET_EXPLORER_URL` | 经核实的主网端点 |

不要把编译进App的RPC key当成秘密。不要编造BENNY合约地址。Arc Testnet资产不计入真实总额，native USDC18与ERC20 USDC6不是两个独立资产。

## 无资金、只读 RPC 检查

```sh
dart run tool/arc_read_smoke.dart
# 可选传入一个公开测试地址来覆盖完整近期历史查询：
dart run tool/arc_read_smoke.dart <public-test-evm-address>
```

输出链ID、USDC精度、gasPrice、block、日志数量和 `broadcasts: 0`。脚本不读取钱包秘密、不签名、不申请faucet、不广播。网络故障需记录所用端点/时间，不能将一次成功保证为服务SLA。

## Android 未注资集成测试

只在专用可丢弃模拟器运行，见 [Arc integration README](../../apps/wallet_client_flutter/integration_test/arc/README.md)：

```sh
flutter test integration_test/arc/arc_emulator_smoke_test.dart \
  -d <dedicated-emulator-id> --flavor liteStore \
  --dart-define=BENNY_EMULATOR_QA=true \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false
```

脚本会创建随机、无资金的测试钱包，PIN `258025`，仅复用带QA标记的测试状态，拒绝未标记现有钱包。`flutter test` 会卸载测试harness；如果要保留该QA钱包用于UI调试，用相同flags执行 `flutter run -t integration_test/arc/arc_emulator_smoke_test.dart`，通过后按 `d` detach，再 `adb install -r` 安装普通APK。不要将含测试harness的APK分发。

这条脚本验证地址/切链/历史读取/错误输入/导币去重，**不广播转账**。真实资金闭环见 TEST_PLAN 的 E2E 组，需新建独立私有测试钱包。

## 原Solana后台/交易回归

[既有 Android QA README](../../apps/wallet_client_flutter/integration_test/android_qa/README.md) 中的 full 流程会按外部配置导入钱包、发送BYC并执行Swap；不是只读测试。本轮未执行。只在授权测试环境和独立测试钱包运行。所需 `.env.config.*.local` 必须保持忽略，不上传秘密。后台具体测试见 [BACKEND_CONTRACTS.md](BACKEND_CONTRACTS.md)。

## 复测与故障定位

- 角标/顺序/布局：组件测试 + 普通APK模拟器截图；不要据此声称签名功能已端到端通过。
- 地址/存储/签名/RPC改动：全量单元测试 + 相关设备/链上用例。
- 活动HTTP400/code35：检查provider允许的log区间；当前Arc配置100块/批，连续扫描1000块，不要盲目退回250块。
- 超时广播：先用本地hash查receipt；不要重复点击重发。
- Arc无EVM账户：检查custody、解锁token、原Sol地址验证；不复制或转换Solana私钥。
- 文档维护：新增测试同步 AUTOMATED_TESTS；每次结果记录代码hash，已有结果保留日期，不覆盖旧证据。
