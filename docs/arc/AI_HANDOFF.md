# AI 接手说明

## 当前任务与仓库

在 `FrankYan2023/benny-wallet-app` 的 **`arc`** 分支继续现有 Flutter 钱包。不要另建应用，也不要误入后台仓库当成手机工程。主工程 `apps/wallet_client_flutter`；所有本文路径默认仓库相对。先运行 `git status`、`git log -8 --oneline`，确认用户尚未提交的修改。

基线 `08cbed3`；功能依次为 `ba322ad` → `4133153` → `9402403` → `67da717`，详细原因见 [修改记录](CHANGELOG.md)。后续文档整理提交不改变这四次功能提交的身份。不要依赖聊天上下文、本机 `/tmp` 文件或原绝对工作目录。

## 产品已确定的方向

- 一个 Benny Wallet 包含多链账户。默认显示 Solana + Arc，右上角筛选网络。
- 复用原资产列表、详情和发送/接收页面；不要重新加入独立 Arc 模块。
- 主操作从左到右：Send、Receive、Swap。Arc-only 隐藏未支持的 Swap；原有功能开关与儿童模式仍生效。
- 币种主图标右下角是链图标；链标签仍明确显示。
- Receive 选择网络后地址/二维码/历史一起对应变化。Send 显式选择网络；切换时清掉旧表单，操作进行时禁止切换。
- Arc Testnet 资产不计入真实美元合计；跨链聚合定价是未来工作。

## 密钥与安全不变量

本地托管类型保存的是加密 **BIP39 助记词文本**（`wallet_records_v1`），不是种子或原始 Solana 私钥。保留原 AES-GCM/PBKDF2 和 Solana derivation/accountIndex/changeIndex。新 EVM 路径固定 `m/44'/60'/0'/0/0`，从相同助记词独立派生；启用前核对原 Solana 地址匹配。相同根下的不同 Solana 派生账户共享该首个 EVM 账户，不能误判为隔离的新 EVM 地址。

MWA/Seed Vault 等无本地助记词托管没有 EVM 能力；必须给出不支持状态。不得用其 PIN marker 或 Solana 私钥充当 BIP39 根。`multichain_v1_*` 仅存公开元数据/活动，不存密钥或签名交易原文。

签名需要有效解锁会话、正确账户、非儿童模式、有效且单次使用的确认数据；广播响应丢失不等于失败，不自动重发。不要为测试关闭这些限制。原生生物识别绑定存在已记录的历史限制，不能宣称已经修复。

## 代码导航

| 入口 | 职责 |
| --- | --- |
| `lib/core/chains/chain_models.dart`、`chain_adapter.dart` | ChainConfig/Account/Asset/Activity/Fee 与链接口 |
| `lib/core/chains/solana_adapter.dart` | 包装现有 SolanaWalletService，保留原发送行为 |
| `lib/core/chains/evm/` | EVM 派生、RPC、安全签名、USDC/ERC-20、交易/日志 |
| `lib/core/chains/arc_chain_config.dart` | 网络 ID、RPC、精度/费用、日志区间、链图标 |
| `lib/features/multichain/providers/` | 活跃钱包到链账户/资产/活动的连接 |
| `lib/features/multichain/data/` | 确认/签名/广播边界、元数据存储 |
| `lib/features/multichain/presentation/portfolio_network_widgets.dart` | 首页过滤、菜单与附加网络资产行 |
| `lib/features/{portfolio,send,receive,asset_detail}/presentation/` | 共用产品界面；Arc 表单嵌入原 Send |
| `lib/features/multichain/presentation/chain_navigation.dart` | 按网络选择历史路由 |
| `lib/app/router.dart` | 登录/儿童模式守卫、旧链接兼容 |
| `packages/design_system/lib/src/widgets/token_row.dart` | 共用币种行与网络角标 |
| `lib/core/network/` | 既有后台 API 与认证；不是 EVM RPC |

表中 `lib/` 开头路径均位于 `apps/wallet_client_flutter/`。

## 下一步优先级

1. 使用 [验证记录](VALIDATION.md) 判断“最新代码已测”与“历史已测”；不要只引用旧的通过数字。
2. 在独立、私有的测试网钱包完成 [TEST_PLAN.md](TEST_PLAN.md) 中 E2E 用例，保存 tx hash、网络、预期/实际余额与回执。不要给公开 QA PIN 或标准测试向量钱包注资。
3. 初始化合规可用的 Xcode/CocoaPods，执行无签名 iOS 构建、模拟器和物理设备安全测试；当前没有 iOS 成功证据。
4. 在后台 staging 环境按 [后台清单](BACKEND_CONTRACTS.md) 回归原 Solana API、认证、通知及权限。没有后台访问证据时，标为未测。
5. 使用受控旧版本测试记录验证升级/恢复；现有 fixture 只证明仓库当前已知格式。
6. 处理剩余本地化、长期历史索引、主网准入/配置评审后再谈发布。

## 每次交接需要写下

日期、实现提交、变更目的、最终行为、改动文件、实际命令与结果、未测/失败原因、风险、下一步。更新 CHANGELOG / TEST_PLAN / VALIDATION；不要把规划的用例标成通过。提交前检查无密钥/个人钱包数据，确认不误提交 APK、构建目录或本机环境文件。
