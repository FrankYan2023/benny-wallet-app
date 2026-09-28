# AI 接手说明

## 2026-09-28 生产只读验收完成

后台运行版本 `abab0b1` 已由 GitHub main 自动部署，Railway deployment `0781842c-3366-4abf-b390-ef566a6f40f9` 为 Active。生产主网 5042、Supabase 读取、Arc USDC 精度/余额/估费/日志/回执查询及原 Solana 登录和余额读取均通过；索引已开启，08:05:23.293Z 成功完成一轮，无 lastError。未注册测试 EVM 账户、未广播交易、未使用资金；索引健康不代表大账户历史回填或实际 FCM 送达已验收。

前后端 `arc` 均已快进合并到 `main` 并保留开发分支。手机运行代码仍为 `460cd44`，本次仅补充文档，未重建或发布商店包。可以开始专用 Android 真机无资金联调；资金闭环、真机通知和存量版本原地升级按测试计划继续。后台配置默认开启 API/索引，主网节点有默认值，既有秘密仍在 Railway；无需另外上传 `.env` 文件。

详细 SQL 版本、发布顺序、线上结果与未验收项目：[后台发布记录](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_RELEASE_2026_09_27.md)。


## 2026-09-27 自动发布与数据库增量

按现有 GitHub main → Railway 自动发布流程交付，不更换服务或部署分支。后台提交 `4b24dab` 已快进合并 main，数据库 SQL 已在 Supabase 执行（远程版本 `20260927142033`，本地源文件 `20260926094915_arc_multichain_services.sql`）；新增 6 表/4 函数，保留原表和钱包数据。生产发布和只读验证的最终状态见 [后台发布记录](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_RELEASE_2026_09_27.md)。

Arc 默认主网 5042，节点/功能开关来自后台版本化配置，既有服务密钥继续由 Railway 管理。手机默认连接 `https://api.gobennyapp.com`，不需要打开测试网或直接 RPC 开关。本地 Circle 主网复查已返回 HTTP 200 / 5042，不再将 09-26 的 403 当成当前结果。

本次手机仅更新文档，没有修改运行代码、密钥存储或 Android/iOS 构建配置。最新既有证据仍为 88 项 Flutter 测试、静态检查、Android full/liteStore debug 和 iOS unsigned debug 通过；没有借此声称受控资金收发、FCM、真机升级或签名发布通过。


## 2026-09-27 存量用户检查

运行代码未改，补充回归后客户端 88 / 后台 23 项通过。真机联调与受控旧版本升级前先读 [EXISTING_USER_ANDROID](EXISTING_USER_ANDROID.md)。不对个人钱包卸载、清数据或用 debug 签名强行覆盖生产包。

## 2026-09-26 当前工作

新增 [MAINNET_PARITY](MAINNET_PARITY.md) 为本轮验收合同；除 Arc Swap/Bridge 外，对齐既有 Solana 的基础钱包能力。后台源码已检查并修改：[benny-wallet / arc](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_MULTICHAIN.md)，`apps/wallet_api/src/multichain`、`src/routes/arc.ts` 和新增 Supabase migration。不要再将后台任务标为“只从客户端推断”。**未部署、未执行远程迁移或真实资金转账。**

客户端默认 `arc-mainnet` / chain ID 5042，经 `ChainBackendClient` → `/v1/arc-rpc`；`ARC_USE_TESTNET=true` 选择测试网，只有同时设置 `ARC_DIRECT_TESTNET_RPC=true` 才可直接访问测试 RPC。旧 `ENABLE_ARC_MAINNET` 不再控制网络。配置切换不会改动密钥、旧测试网资产也不会被当成主网余额。

新增账户证明、云 token 同步、合约身份价格、总额汇总、后台历史分页、网络化通知字段/去重。`backend_history_controller.dart` 保留本地提交并轮询后台；`chain_backend_client.dart` 在每次请求前后检查当前解锁账户、只向 API 主机发送凭据。主网 RPC 的费用来自实时数据，不使用测试网固定下限。

下一步以 VALIDATION 最新条目为准：完成 staging/生产迁移与部署，核实节点访问、索引追赶、通知和受控资金收发；iOS 无签名 debug 已通过，仍需模拟器/真机及签名发布验证。不要把 mocked API/PGlite 成功等同远程环境成功。

## 仓库与前期历史

在 `FrankYan2023/benny-wallet-app` 的 **`arc`** 分支继续现有 Flutter 钱包。不要另建应用，也不要误入后台仓库当成手机工程。主工程 `apps/wallet_client_flutter`；所有本文路径默认仓库相对。先运行 `git status`、`git log -8 --oneline`，确认用户尚未提交的修改。

基线 `08cbed3`；功能依次为 `ba322ad` → `4133153` → `9402403` → `67da717`，详细原因见 [修改记录](CHANGELOG.md)。后续文档整理提交不改变这四次功能提交的身份。不要依赖聊天上下文、本机 `/tmp` 文件或原绝对工作目录。

## 产品已确定的方向

- 一个 Benny Wallet 包含多链账户。默认显示 Solana + Arc，右上角筛选网络。
- 复用原资产列表、详情和发送/接收页面；不要重新加入独立 Arc 模块。
- 主操作从左到右：Send、Receive、Swap。Arc-only 隐藏未支持的 Swap；原有功能开关与儿童模式仍生效。
- 币种主图标右下角是链图标；链标签仍明确显示。
- Receive 选择网络后地址/二维码/历史一起对应变化。Send 显式选择网络；切换时清掉旧表单，操作进行时禁止切换。
- Arc Testnet 资产不计入真实美元合计；主网报价按合约身份映射，未知价格和余额不可用必须明确提示。

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
| `lib/core/network/` | 既有后台 API 与认证；由 ChainBackendClient 复用认证 |
| `lib/core/chains/chain_backend_client.dart` | Arc 后台 RPC、固定账户证明、资产/历史 DTO |

表中 `lib/` 开头路径均位于 `apps/wallet_client_flutter/`。

## 下一步优先级

1. 使用 [验证记录](VALIDATION.md) 判断“最新代码已测”与“历史已测”；不要只引用旧的通过数字。
2. 在独立、私有的测试网钱包完成 [TEST_PLAN.md](TEST_PLAN.md) 中 E2E 用例，保存 tx hash、网络、预期/实际余额与回执。不要给公开 QA PIN 或标准测试向量钱包注资。
3. 在已通过无签名 debug 构建的基础上执行 iOS 模拟器、物理设备安全测试及带真实 Firebase 配置的签名发布构建；不能把编译通过当作设备验收。
4. 在后台 staging 环境按 [后台清单](BACKEND_CONTRACTS.md) 回归原 Solana API、认证、通知及权限。没有后台访问证据时，标为未测。
5. 使用受控旧版本测试记录验证升级/恢复；现有 fixture 只证明仓库当前已知格式。
6. 处理剩余本地化，验证后台长期历史索引/主网配置和运维容量后再发布。

## 每次交接需要写下

日期、实现提交、变更目的、最终行为、改动文件、实际命令与结果、未测/失败原因、风险、下一步。更新 CHANGELOG / TEST_PLAN / VALIDATION；不要把规划的用例标成通过。提交前检查无密钥/个人钱包数据，确认不误提交 APK、构建目录或本机环境文件。
