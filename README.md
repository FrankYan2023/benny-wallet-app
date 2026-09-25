# Benny Wallet

Benny Wallet 是现有的 Flutter 自托管钱包，主要移动端工程为 [`apps/wallet_client_flutter`](apps/wallet_client_flutter)。`arc` 分支在保留 Solana 功能的基础上，加入通用 EVM 架构与 Arc Testnet 支持。不是新建钱包应用，也不包含服务端工程。

## 当前功能

- 同一兼容 BIP39 根钱包独立派生原有 Solana 账户与 EVM 账户；密钥留在设备上。
- 首页默认显示两条链，余额卡右上角可切换 All / Solana / Arc；资产图标右下角显示所属链。
- 操作顺序为 **Send → Receive → Swap**。Arc 收发整合进原有页面，显式选择网络；Arc-only 不展示尚未支持的 Swap。
- Arc USDC 余额、收款地址/二维码、ERC-20 导入（含经核实的 BENNY 合约）、费用估算、交易确认/签名/广播与近期活动。
- 保留 Solana 发送、接收、Swap、资产/DeFi、PIN/生物识别、儿童模式和现有后台功能。
- 测试网资产不计入真实美元总额。Arc Swap、跨链桥、完整 WalletConnect 和 DApp 浏览器不在当前 MVP 范围。

## 交付状态

截至 2026-09-25，代码提交 `67da717`：72 项本地单元/组件测试通过，静态分析通过，Android 调试包已构建并在模拟器检查。**完整 MVP 尚未验收**：真实测试网资金收发、物理设备安全回归、iOS 构建和服务端端到端回归仍待完成。iOS 当前受开发机 Xcode 许可/初始化阻塞。最新证据见 [验证记录](docs/arc/VALIDATION.md)，不要把测试用例清单当成通过记录。

当前代码默认 Arc Testnet（chain ID `5042002`）。主网配置是此前文档核对的快照，发布前须重新核对官方资料和接入条件；禁止仅因存在配置就宣称主网可用。

## 开发入口

环境参考：Flutter 3.41.6 / Dart 3.11.4；依赖以 `pubspec.lock` 为准。需要 Android SDK/JDK；iOS 另需已初始化的 Xcode/CocoaPods。

```sh
git clone --branch arc https://github.com/FrankYan2023/benny-wallet-app.git
cd benny-wallet-app/apps/wallet_client_flutter
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter run --flavor liteStore -d <android-device-id> \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false
```

`liteStore` 是 Android flavor，**不等同于** `STORE_MODE=lite`；后者会隐藏 Swap 等功能。上面的 UI 调试命令保留当前默认功能开关。商店审核构建应使用明确的发布配置，见 [开发与测试操作指南](docs/arc/DEVELOPMENT.md)。不要对个人钱包运行会创建/导入测试钱包的集成脚本。

## 文档与 AI 接手

| 文档 | 内容 |
| --- | --- |
| [Arc 文档索引](docs/arc/README.md) | 当前状态、目录、阅读顺序、遗留事项 |
| [AI 接手说明](docs/arc/AI_HANDOFF.md) | 项目定位、约束、代码入口、下次工作顺序 |
| [完整修改历史](docs/arc/CHANGELOG.md) | 每次提交的原因/行为变化、决策、完整文件清单 |
| [架构与密钥审计](MILESTONE_2_ARC.md) | 实际存储、派生、多链/RPC/费用模型和历史验证 |
| [全部测试计划](docs/arc/TEST_PLAN.md) | 前端、链服务、后台、安全、平台的用例与发布门槛 |
| [现有自动化测试目录](docs/arc/AUTOMATED_TESTS.md) | 测试文件和逐条测试名称，区分自动化与未执行端到端 |
| [后台接口与联调](docs/arc/BACKEND_CONTRACTS.md) | 从客户端发现的真实接口、边界和后台测试要求 |
| [验证记录](docs/arc/VALIDATION.md) | 哪个版本、何时、如何验证、结果及未测项目 |
| [开发指南](docs/arc/DEVELOPMENT.md) | 构建、配置、模拟器、复测、故障排查 |

以后让 AI 接手时，可直接要求：**先阅读 `AGENTS.md`、`docs/arc/AI_HANDOFF.md` 和 `docs/arc/CHANGELOG.md`，对照实际 Git HEAD 与验证记录，再继续未完成的任务。**

## 仓库边界

- `apps/wallet_client_flutter/`：现有客户端。
- `packages/design_system/`：共享视觉组件。
- `packages/shared_types/`：现有共享类型。
- 后台在独立仓库 `FrankYan2023/benny-wallet`；本分支没有后台部署、数据库迁移或后台源码修改。
- 原有 Web 目标保留；本轮未验证 Web，不据此宣称多链 Web 可发布。

## License

MIT。第三方链标识归对应权利人；Arc 图标来源见 [资源说明](apps/wallet_client_flutter/assets/chain_logos/README.md)。
