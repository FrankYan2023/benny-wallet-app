# Arc 完整修改记录

历史基线：`08cbed3`（Release Android v0.0.50）。目标分支 `arc` 从原 `codex/milestone-2-arc` 完整延续提交，没有压成一个无法追溯的快照。以下行为描述为各提交当时状态；后面的交互改动覆盖前面的中间设计。

最新结果以 [VALIDATION.md](VALIDATION.md) 为准。架构细节见 [MILESTONE_2_ARC.md](../../MILESTONE_2_ARC.md)。

## 2026-09-27 · 存量用户保护检查与真机联调条件

在 `460cd44` 客户端 / `283f8a5` 后台运行代码上补回归；没有为本次检查改写运行代码或密钥数据。客户端 `wallet_storage_regression_test.dart` 增强旧加密记录派生 Arc 后的不变性；`widgets_test.dart` 增加 Arc 不可用时原资产/网络选择及不支持 Arc 时 Solana 收款恢复测试。后台 `arc.test.ts` 增加插件路由隔离断言。

更新本日志、VALIDATION、AUTOMATED_TESTS、TEST_PLAN、README 索引、AI_HANDOFF，并新增 [EXISTING_USER_ANDROID](EXISTING_USER_ANDROID.md)：已审查边界、共享服务风险、生产接口前提、同包名/同签名覆盖升级及禁止清数据绕过冲突。客户端 88 / 后台 23 项全通过，分析与测试类型检查通过。生产链上/历史版本真机升级仍待验收；没有执行部署或真机安装。

## 2026-09-26–27 · Arc 主网后台服务与双链能力对齐

客户端从 `6f8b623` 继续，后台从 `db53c5a` 新建 `arc`，对应提交 [`283f8a5`](https://github.com/FrankYan2023/benny-wallet/commit/283f8a5)；本条对应所在提交，使用 Git blame/log 获取不可变 commit。后台完整记录见 [ARC_CHANGELOG](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_CHANGELOG.md)。

原因：初版主要依赖公开测试网、设备近期日志，尚未对齐 Solana 的后台资产/持久历史/通知/多设备能力。用户要求统一架构，除 Arc Swap/Bridge 外完成基础钱包功能。

- 默认网络改为 Mainnet 5042；所有普通 Arc 请求复用现有钱包 Bearer 会话，经新 `/v1/arc-rpc` 和链服务接口。测试网及直接 RPC QA 必须显式启用；主网没有绕过后台的自动 fallback。
- 账户绑定采用手机本地 EIP-191 固定证明，逐项验证挑战文案、根账户、网络、地址与时效；后台验签并原子消费。助记词、私钥和交易签名仍留手机，Solana 路径和旧加密数据不迁移。
- 新增云代币同步、合约身份价格映射、两链资产总额；未知报价、坏代币与后台不可用明确提示，不伪装成零余额，也不计入测试网价值。
- 共用历史页面接入后台分页/回填状态，保留本地提交并轮询收据；新增链/根账户通知字段、事件去重、已读/删除保持和并发收件箱写入串行化。
- 延续 All/Solana/Arc 筛选、Send→Receive→Swap、币种链角标及原收发入口；网络逻辑留在配置、适配器及服务中。
- iOS Firebase 配置改为构建时受控复制：Debug 可无私有 plist，Release/Profile 必须真实配置；修复新 checkout 无签名 debug 构建失败。
- 新增 14 项客户端测试、主网 HTTP fixture 原生脚本；后台增加 22 项服务/SQL 测试、6 张表/4 个函数、FCM outbox 与部署开关。完整目标、测试矩阵、部署/回滚、已测/未测记录同步更新。

验证：Flutter 86、后台 22 全通过；分析、Android full/liteStore 与 iOS 无签名 debug 构建通过；Android 主网 fixture full/lite 与真实公共测试网 full 通过。精确日期/flags/限制见 [VALIDATION](VALIDATION.md)。未执行远程迁移、生产部署、真实资金转账或真实 FCM；主网探测仍 HTTP 403。不能将此提交标为已正式上线。

本轮完整文件清单（含运行代码、平台、测试、交接文档；Git diff 为权威）：

- [AGENTS.md](../../AGENTS.md)
- [MILESTONE_2_ARC.md](../../MILESTONE_2_ARC.md)
- [README.md](../../README.md)
- [apps/wallet_client_flutter/integration_test/arc/README.md](../../apps/wallet_client_flutter/integration_test/arc/README.md)
- [apps/wallet_client_flutter/integration_test/arc/arc_backend_ui_test.dart](../../apps/wallet_client_flutter/integration_test/arc/arc_backend_ui_test.dart)
- [apps/wallet_client_flutter/ios/Runner.xcodeproj/project.pbxproj](../../apps/wallet_client_flutter/ios/Runner.xcodeproj/project.pbxproj)
- [apps/wallet_client_flutter/ios/scripts/copy_firebase_config.sh](../../apps/wallet_client_flutter/ios/scripts/copy_firebase_config.sh)
- [apps/wallet_client_flutter/lib/app/router.dart](../../apps/wallet_client_flutter/lib/app/router.dart)
- [apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart](../../apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart)
- [apps/wallet_client_flutter/lib/core/chains/chain_backend_client.dart](../../apps/wallet_client_flutter/lib/core/chains/chain_backend_client.dart)
- [apps/wallet_client_flutter/lib/core/chains/chain_models.dart](../../apps/wallet_client_flutter/lib/core/chains/chain_models.dart)
- [apps/wallet_client_flutter/lib/features/multichain/data/backend_history_controller.dart](../../apps/wallet_client_flutter/lib/features/multichain/data/backend_history_controller.dart)
- [apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart)
- [apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart)
- [apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart](../../apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart)
- [apps/wallet_client_flutter/lib/features/multichain/providers/multichain_providers.dart](../../apps/wallet_client_flutter/lib/features/multichain/providers/multichain_providers.dart)
- [apps/wallet_client_flutter/lib/features/notifications/data/notification_inbox_repository.dart](../../apps/wallet_client_flutter/lib/features/notifications/data/notification_inbox_repository.dart)
- [apps/wallet_client_flutter/lib/features/notifications/domain/notification_message.dart](../../apps/wallet_client_flutter/lib/features/notifications/domain/notification_message.dart)
- [apps/wallet_client_flutter/lib/features/notifications/presentation/pages/notifications_page.dart](../../apps/wallet_client_flutter/lib/features/notifications/presentation/pages/notifications_page.dart)
- [apps/wallet_client_flutter/lib/features/notifications/presentation/providers/notification_inbox_provider.dart](../../apps/wallet_client_flutter/lib/features/notifications/presentation/providers/notification_inbox_provider.dart)
- [apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart](../../apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart)
- [apps/wallet_client_flutter/test/core/chains/chain_backend_client_test.dart](../../apps/wallet_client_flutter/test/core/chains/chain_backend_client_test.dart)
- [apps/wallet_client_flutter/test/features/multichain/portfolio_value_test.dart](../../apps/wallet_client_flutter/test/features/multichain/portfolio_value_test.dart)
- [apps/wallet_client_flutter/test/features/multichain/widgets_test.dart](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart)
- [apps/wallet_client_flutter/test/features/notifications/chain_notification_test.dart](../../apps/wallet_client_flutter/test/features/notifications/chain_notification_test.dart)
- [docs/arc/AI_HANDOFF.md](../../docs/arc/AI_HANDOFF.md)
- [docs/arc/AUTOMATED_TESTS.md](../../docs/arc/AUTOMATED_TESTS.md)
- [docs/arc/BACKEND_CONTRACTS.md](../../docs/arc/BACKEND_CONTRACTS.md)
- [docs/arc/CHANGELOG.md](../../docs/arc/CHANGELOG.md)
- [docs/arc/DEVELOPMENT.md](../../docs/arc/DEVELOPMENT.md)
- [docs/arc/MAINNET_PARITY.md](../../docs/arc/MAINNET_PARITY.md)
- [docs/arc/README.md](../../docs/arc/README.md)
- [docs/arc/TEST_PLAN.md](../../docs/arc/TEST_PLAN.md)
- [docs/arc/VALIDATION.md](../../docs/arc/VALIDATION.md)
- [docs/arc/evidence/mainnet-source-manifest.txt](../../docs/arc/evidence/mainnet-source-manifest.txt)

## 2026-09-19 · 多链基础与Arc Testnet基本服务

提交：[`ba322ad`](https://github.com/FrankYan2023/benny-wallet-app/commit/ba322ad1e6c5f2ef3c9e9c04c7bd435e0d7d757e)。

- 先审计现有加密助记词、Solana派生和外部托管；不改写已有钱包记录。
- 引入ChainAdapter/ChainConfig/Account/Asset/Fee/Activity；SolanaAdapter包装旧服务，EvmAdapter统一RPC、ABI、gas、交易和日志。
- 从同一兼容BIP39根独立派生EVM路径；增加USDC去重、ERC20导入、EIP1559签名/广播、确认约束和metadata存储。
- 增加EIP191/EIP712和意图解码接口；不实现Swap/Bridge/完整WalletConnect。
- 增加存储fixture/派生/链服务/组件回归和只读RPC脚本。此时额外网络入口是中间版本，随后由9402403统一。

验证/限制：当时68项测试、分析、Android debug构建和只读RPC检查通过；iOS许可阻塞；未完成有资金端到端。

涉及文件：

- [`MILESTONE_2_ARC.md`](../../MILESTONE_2_ARC.md)
- [`apps/wallet_client_flutter/lib/app/router.dart`](../../apps/wallet_client_flutter/lib/app/router.dart)
- [`apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart`](../../apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart)
- [`apps/wallet_client_flutter/lib/core/chains/chain_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/chain_adapter.dart)
- [`apps/wallet_client_flutter/lib/core/chains/chain_models.dart`](../../apps/wallet_client_flutter/lib/core/chains/chain_models.dart)
- [`apps/wallet_client_flutter/lib/core/chains/evm/evm_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_adapter.dart)
- [`apps/wallet_client_flutter/lib/core/chains/evm/evm_key_service.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_key_service.dart)
- [`apps/wallet_client_flutter/lib/core/chains/evm/evm_rpc.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_rpc.dart)
- [`apps/wallet_client_flutter/lib/core/chains/evm/evm_signing_intent.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_signing_intent.dart)
- [`apps/wallet_client_flutter/lib/core/chains/solana_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/solana_adapter.dart)
- [`apps/wallet_client_flutter/lib/features/auth/data/solana_wallet_service.dart`](../../apps/wallet_client_flutter/lib/features/auth/data/solana_wallet_service.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/data/chain_transfer_controller.dart`](../../apps/wallet_client_flutter/lib/features/multichain/data/chain_transfer_controller.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/data/multichain_store.dart`](../../apps/wallet_client_flutter/lib/features/multichain/data/multichain_store.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/chain_widgets.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/chain_widgets.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/token_import_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/token_import_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/providers/multichain_providers.dart`](../../apps/wallet_client_flutter/lib/features/multichain/providers/multichain_providers.dart)
- [`apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart`](../../apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart)
- [`apps/wallet_client_flutter/lib/features/receive/presentation/pages/receive_page.dart`](../../apps/wallet_client_flutter/lib/features/receive/presentation/pages/receive_page.dart)
- [`apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart`](../../apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart)
- [`apps/wallet_client_flutter/pubspec.lock`](../../apps/wallet_client_flutter/pubspec.lock)
- [`apps/wallet_client_flutter/pubspec.yaml`](../../apps/wallet_client_flutter/pubspec.yaml)
- [`apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart`](../../apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart)
- [`apps/wallet_client_flutter/test/core/chains/evm_rpc_test.dart`](../../apps/wallet_client_flutter/test/core/chains/evm_rpc_test.dart)
- [`apps/wallet_client_flutter/test/core/chains/solana_adapter_test.dart`](../../apps/wallet_client_flutter/test/core/chains/solana_adapter_test.dart)
- [`apps/wallet_client_flutter/test/features/auth/wallet_storage_regression_test.dart`](../../apps/wallet_client_flutter/test/features/auth/wallet_storage_regression_test.dart)
- [`apps/wallet_client_flutter/test/features/multichain/chain_transfer_controller_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/chain_transfer_controller_test.dart)
- [`apps/wallet_client_flutter/test/features/multichain/multichain_store_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/multichain_store_test.dart)
- [`apps/wallet_client_flutter/test/features/multichain/widgets_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart)
- [`apps/wallet_client_flutter/tool/arc_read_smoke.dart`](../../apps/wallet_client_flutter/tool/arc_read_smoke.dart)

## 2026-09-24 · Android实际交互与公共RPC历史修复

提交：[`4133153`](https://github.com/FrankYan2023/benny-wallet-app/commit/413315362e7dd54f3093c1b05296b1bae0771a18)。

- 修复PIN解锁后页面释放期间的状态更新，避免模拟器解锁异常。
- 将Receive历史路由与选中网络关联；儿童模式隐藏不支持的导入入口。
- 公共RPC拒绝250块日志请求；调整为可配置100块批次，仍连续扫描1000块，补充断言。
- 加入真实Android安全存储/路由的未注资集成测试，支持保留专用QA钱包的调试流程。

验证/限制：当时70项测试、分析、Android构建与43秒模拟器测试通过；检查键盘/130%字体；未广播。

涉及文件：

- [`MILESTONE_2_ARC.md`](../../MILESTONE_2_ARC.md)
- [`apps/wallet_client_flutter/integration_test/arc/README.md`](../../apps/wallet_client_flutter/integration_test/arc/README.md)
- [`apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart`](../../apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart)
- [`apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart`](../../apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart)
- [`apps/wallet_client_flutter/lib/core/chains/chain_models.dart`](../../apps/wallet_client_flutter/lib/core/chains/chain_models.dart)
- [`apps/wallet_client_flutter/lib/core/chains/evm/evm_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_adapter.dart)
- [`apps/wallet_client_flutter/lib/features/auth/presentation/pages/unlock_page.dart`](../../apps/wallet_client_flutter/lib/features/auth/presentation/pages/unlock_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/chain_navigation.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/chain_navigation.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart)
- [`apps/wallet_client_flutter/lib/features/receive/presentation/pages/receive_page.dart`](../../apps/wallet_client_flutter/lib/features/receive/presentation/pages/receive_page.dart)
- [`apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart`](../../apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart)
- [`apps/wallet_client_flutter/test/features/multichain/widgets_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart)
- [`apps/wallet_client_flutter/tool/arc_read_smoke.dart`](../../apps/wallet_client_flutter/tool/arc_read_smoke.dart)

## 2026-09-25 · Arc整合回原有钱包界面

提交：[`9402403`](https://github.com/FrankYan2023/benny-wallet-app/commit/94024035c43523307ad58935a0e49c8ab13e1ecb)。

- 余额卡右上角All/Solana/Arc选择；默认同时显示两链资产，不再单独展示Arc模块。
- 复用TokenRow、资产详情、原Send/Receive入口；Arc发送表单嵌入共用Send。
- 发送显式选择网络；切换清空表单，交易操作期间禁止切换。资产详情收发保持所属网络。
- 旧network-send链接重定向；旧网络页面仅保留活动；Arc-only隐藏尚未支持的Swap。
- 空Solana钱包显示零余额资产行；Arc测试资产不进入真实美元总额。

验证/限制：当时72项测试、分析、Android构建通过；统一界面模拟器集成46秒通过，普通APK手动检查。

涉及文件：

- [`MILESTONE_2_ARC.md`](../../MILESTONE_2_ARC.md)
- [`apps/wallet_client_flutter/integration_test/arc/README.md`](../../apps/wallet_client_flutter/integration_test/arc/README.md)
- [`apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart`](../../apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart)
- [`apps/wallet_client_flutter/lib/app/router.dart`](../../apps/wallet_client_flutter/lib/app/router.dart)
- [`apps/wallet_client_flutter/lib/features/asset_detail/presentation/pages/asset_detail_page.dart`](../../apps/wallet_client_flutter/lib/features/asset_detail/presentation/pages/asset_detail_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/chain_widgets.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/chain_widgets.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart)
- [`apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart`](../../apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart)
- [`apps/wallet_client_flutter/lib/features/send/presentation/pages/send_compose_page.dart`](../../apps/wallet_client_flutter/lib/features/send/presentation/pages/send_compose_page.dart)
- [`apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart`](../../apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart)
- [`apps/wallet_client_flutter/test/features/multichain/widgets_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart)
- [`packages/design_system/lib/src/widgets/token_row.dart`](../../packages/design_system/lib/src/widgets/token_row.dart)

## 2026-09-25 · 操作顺序与真实链图标

提交：[`67da717`](https://github.com/FrankYan2023/benny-wallet-app/commit/67da717332766dd2c2191f87948922bf1adec573)。

- 首页操作顺序改为Send→Receive→Swap，保留功能开关和儿童模式限制。
- 币种图标右下角从通用layers标记替换为实际所属链；链配置提供iconAsset，设计系统不判断链协议。
- Arc官方图标本地打包，Solana复用已有资源；首页与Solana发送选币列表显示网络角标。

验证/限制：当时9项相关组件测试、分析、Android构建13.3秒通过并安装检查；发布文档整理时在同一功能代码上重新执行全量72项测试通过。

涉及文件：

- [`MILESTONE_2_ARC.md`](../../MILESTONE_2_ARC.md)
- [`apps/wallet_client_flutter/assets/chain_logos/README.md`](../../apps/wallet_client_flutter/assets/chain_logos/README.md)
- [`apps/wallet_client_flutter/assets/chain_logos/arc.png`](../../apps/wallet_client_flutter/assets/chain_logos/arc.png)
- [`apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart`](../../apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart)
- [`apps/wallet_client_flutter/lib/core/chains/chain_models.dart`](../../apps/wallet_client_flutter/lib/core/chains/chain_models.dart)
- [`apps/wallet_client_flutter/lib/core/chains/solana_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/solana_adapter.dart)
- [`apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart)
- [`apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart`](../../apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart)
- [`apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart`](../../apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart)
- [`apps/wallet_client_flutter/pubspec.yaml`](../../apps/wallet_client_flutter/pubspec.yaml)
- [`packages/design_system/lib/src/widgets/token_row.dart`](../../packages/design_system/lib/src/widgets/token_row.dart)

## 2026-09-25 · GitHub arc 分支与文档交接

目的：让后续AI/工程师直接从仓库读取修改历史、最终交互、测试范围和真实验收状态。此文档提交位于上述4次实现提交之后，可通过 `git log -- docs/arc README.md AGENTS.md MILESTONE_2_ARC.md` 定位。

- 新建 `arc` 分支保留完整提交历史；上传代码与文档，不合并main、不发布商店包、不部署后台。
- 重写根README，增加AGENTS入口、文档索引、AI接手、前后台测试计划、逐条自动化目录、接口清单、开发指南与验证证据。
- 将本机截图转为仓库内文档资产；保留旧阶段结果并标明适用提交，避免过期“全部通过”误导。
- 最新功能代码的pub get、静态分析、72项单元/组件测试重新执行通过。后台服务端、资金闭环、物理安全与iOS仍待验收。

## 决策与保留事项

| 决策 | 原因 / 不可误改的边界 |
| --- | --- |
| 一根钱包多链账户 | EVM独立派生，不转换Solana私钥；同根多个Solana index共享首个EVM账户 |
| 一个USDC经济余额 | native18精度用于gas，ERC206精度用于用户转账；禁止双算 |
| UI资产优先 | 不恢复独立Arc模块；网络在收发中明确选择 |
| 近期历史窗口 | 移动端不从创世块扫描；1000块和本地100条是当前边界 |
| 先Testnet | 主网参数/准入必须启用前重查，代码存在不等于可发布 |
| 保留Solana后台 | 本分支没有后台源码/数据库改动，后台回归需独立环境 |
| 文档与结果分离 | TEST_PLAN是待执行范围；VALIDATION记录真实结果与代码版本 |

## 相对基线的完整实现文件清单

范围固定 `08cbed3..67da717`，不包含之后的文档整理。A=新增，M=修改；共41个文件。精确补丁使用 `git diff 08cbed3..67da717`。

| 状态 | 文件 |
| --- | --- |
| A | [`MILESTONE_2_ARC.md`](../../MILESTONE_2_ARC.md) |
| A | [`apps/wallet_client_flutter/assets/chain_logos/README.md`](../../apps/wallet_client_flutter/assets/chain_logos/README.md) |
| A | [`apps/wallet_client_flutter/assets/chain_logos/arc.png`](../../apps/wallet_client_flutter/assets/chain_logos/arc.png) |
| A | [`apps/wallet_client_flutter/integration_test/arc/README.md`](../../apps/wallet_client_flutter/integration_test/arc/README.md) |
| A | [`apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart`](../../apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart) |
| M | [`apps/wallet_client_flutter/lib/app/router.dart`](../../apps/wallet_client_flutter/lib/app/router.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart`](../../apps/wallet_client_flutter/lib/core/chains/arc_chain_config.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/chain_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/chain_adapter.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/chain_models.dart`](../../apps/wallet_client_flutter/lib/core/chains/chain_models.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/evm/evm_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_adapter.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/evm/evm_key_service.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_key_service.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/evm/evm_rpc.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_rpc.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/evm/evm_signing_intent.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_signing_intent.dart) |
| A | [`apps/wallet_client_flutter/lib/core/chains/solana_adapter.dart`](../../apps/wallet_client_flutter/lib/core/chains/solana_adapter.dart) |
| M | [`apps/wallet_client_flutter/lib/features/asset_detail/presentation/pages/asset_detail_page.dart`](../../apps/wallet_client_flutter/lib/features/asset_detail/presentation/pages/asset_detail_page.dart) |
| M | [`apps/wallet_client_flutter/lib/features/auth/data/solana_wallet_service.dart`](../../apps/wallet_client_flutter/lib/features/auth/data/solana_wallet_service.dart) |
| M | [`apps/wallet_client_flutter/lib/features/auth/presentation/pages/unlock_page.dart`](../../apps/wallet_client_flutter/lib/features/auth/presentation/pages/unlock_page.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/data/chain_transfer_controller.dart`](../../apps/wallet_client_flutter/lib/features/multichain/data/chain_transfer_controller.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/data/multichain_store.dart`](../../apps/wallet_client_flutter/lib/features/multichain/data/multichain_store.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/presentation/chain_navigation.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/chain_navigation.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/presentation/chain_widgets.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/chain_widgets.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_page.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/network_send_page.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/portfolio_network_widgets.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/presentation/token_import_page.dart`](../../apps/wallet_client_flutter/lib/features/multichain/presentation/token_import_page.dart) |
| A | [`apps/wallet_client_flutter/lib/features/multichain/providers/multichain_providers.dart`](../../apps/wallet_client_flutter/lib/features/multichain/providers/multichain_providers.dart) |
| M | [`apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart`](../../apps/wallet_client_flutter/lib/features/portfolio/presentation/pages/portfolio_page.dart) |
| M | [`apps/wallet_client_flutter/lib/features/receive/presentation/pages/receive_page.dart`](../../apps/wallet_client_flutter/lib/features/receive/presentation/pages/receive_page.dart) |
| M | [`apps/wallet_client_flutter/lib/features/send/presentation/pages/send_compose_page.dart`](../../apps/wallet_client_flutter/lib/features/send/presentation/pages/send_compose_page.dart) |
| M | [`apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart`](../../apps/wallet_client_flutter/lib/features/send/presentation/pages/send_page.dart) |
| M | [`apps/wallet_client_flutter/pubspec.lock`](../../apps/wallet_client_flutter/pubspec.lock) |
| M | [`apps/wallet_client_flutter/pubspec.yaml`](../../apps/wallet_client_flutter/pubspec.yaml) |
| A | [`apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart`](../../apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart) |
| A | [`apps/wallet_client_flutter/test/core/chains/evm_rpc_test.dart`](../../apps/wallet_client_flutter/test/core/chains/evm_rpc_test.dart) |
| A | [`apps/wallet_client_flutter/test/core/chains/solana_adapter_test.dart`](../../apps/wallet_client_flutter/test/core/chains/solana_adapter_test.dart) |
| A | [`apps/wallet_client_flutter/test/features/auth/wallet_storage_regression_test.dart`](../../apps/wallet_client_flutter/test/features/auth/wallet_storage_regression_test.dart) |
| A | [`apps/wallet_client_flutter/test/features/multichain/chain_transfer_controller_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/chain_transfer_controller_test.dart) |
| A | [`apps/wallet_client_flutter/test/features/multichain/multichain_store_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/multichain_store_test.dart) |
| A | [`apps/wallet_client_flutter/test/features/multichain/widgets_test.dart`](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart) |
| A | [`apps/wallet_client_flutter/tool/arc_read_smoke.dart`](../../apps/wallet_client_flutter/tool/arc_read_smoke.dart) |
| M | [`packages/design_system/lib/src/widgets/token_row.dart`](../../packages/design_system/lib/src/widgets/token_row.dart) |

## 文档整理文件清单

- [`AGENTS.md`](../../AGENTS.md)
- [`README.md`](../../README.md)
- [`MILESTONE_2_ARC.md`](../../MILESTONE_2_ARC.md)
- [`docs/arc/AI_HANDOFF.md`](../../docs/arc/AI_HANDOFF.md)
- [`docs/arc/AUTOMATED_TESTS.md`](../../docs/arc/AUTOMATED_TESTS.md)
- [`docs/arc/BACKEND_CONTRACTS.md`](../../docs/arc/BACKEND_CONTRACTS.md)
- [`docs/arc/CHANGELOG.md`](../../docs/arc/CHANGELOG.md)
- [`docs/arc/DEVELOPMENT.md`](../../docs/arc/DEVELOPMENT.md)
- [`docs/arc/README.md`](../../docs/arc/README.md)
- [`docs/arc/TEST_PLAN.md`](../../docs/arc/TEST_PLAN.md)
- [`docs/arc/VALIDATION.md`](../../docs/arc/VALIDATION.md)
- [`docs/arc/evidence/analysis.txt`](../../docs/arc/evidence/analysis.txt)
- [`docs/arc/evidence/android-build.txt`](../../docs/arc/evidence/android-build.txt)
- [`docs/arc/evidence/home-network-badges.png`](../../docs/arc/evidence/home-network-badges.png)
- [`docs/arc/evidence/shared-receive.png`](../../docs/arc/evidence/shared-receive.png)
- [`docs/arc/evidence/shared-send.png`](../../docs/arc/evidence/shared-send.png)
- [`docs/arc/evidence/unit-widget-tests.txt`](../../docs/arc/evidence/unit-widget-tests.txt)

后续修改追加新日期条目，记录：原因、最终行为、文件、代码提交、实际测试、剩余事项。历史结果不要原地改写成新状态。

## 2026-09-25 · 显式 Android Full/Lite 验收增补

后续于 `c7b3c2d`，没有改动运行时代码、密钥或网络常量。

- 现有Android原生集成加入按钮顺序、链角标、Arc-only Swap隐藏，以及full/lite独立功能模式的断言。
- 点击真实菜单项以消除文本子节点hit-test警告；保留无资金、无签名/广播、拒绝非QA钱包的限制。
- full+STORE_MODE=full测试73秒通过；liteStore+STORE_MODE=lite测试39秒通过；分析10.8秒通过。
- 补查Android flavor构建、测试后恢复普通APK，具体构建结果与设备限制见VALIDATION。此记录不宣称Seeker硬件、签名release或iOS通过。
- 更新集成README、测试计划/目录、根README、索引、原里程碑和验证记录；保留旧阶段日志，新增脱敏runner摘要。

变更文件：
- `apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart`
- `apps/wallet_client_flutter/integration_test/arc/README.md`
- `README.md`、`MILESTONE_2_ARC.md`
- `docs/arc/{README,CHANGELOG,AUTOMATED_TESTS,TEST_PLAN,DEVELOPMENT,VALIDATION}.md`
- `docs/arc/evidence/android-{full-smoke,lite-smoke,acceptance-analysis}.txt`
- 构建/普通APK检查的额外证据文件在VALIDATION中逐项链接。

剩余：私有测试钱包有资金闭环、后台staging联调、物理设备安全回归、iOS环境/构建、release配置；93项计划未全部通过，72项单元测试仍是上次相同运行时代码的结果。
