# Arc 完整修改记录

## 2026-10-03 · Seeker 真机调试与生产复查

Seeker Android16独立新装普通full debug，保留旧Lite，生产API/Arc默认主网5042；构建/安装/欢迎页/调试连接通过。SeekerVault默认开启但未验收，持有人私有无资金钱包/PIN初始化待完成。运行基线a2bc494，无应用源码/后台/数据库改动。

电脑只读认证/config/RPC/USDC精度/费用/receipt/logs/原Solana余额通过；索引health报重试失败，带indexer断言的探测失败，未用只读通过覆盖故障。新增ANDROID_PHYSICAL_DEBUG，更新AI_HANDOFF、DEVELOPMENT、README与VALIDATION，记录启动参数、包隔离/旧版升级边界及真机待测顺序。未增删自动测试或重跑iOS。

## 2026-10-03 · 首页网络筛选与余额分行

修复首页120px网络筛选框与总余额共用Stack而互相覆盖的问题。余额卡片顶部改为独立行：左侧使用已有本地化Total Balance标签，右侧All/链筛选；总金额在下一行使用完整内容宽度居中缩放。移除金额左右88px预留，卡片顶部内边距调整为16px。控件蒙版不再叠在余额上，长金额也不与控件争用空间。

文件：portfolio_page.dart；复用既有首页组件测试，增加真实PortfolioPage多网络与窄屏截图，无新增/删除测试。筛选/总额计算、网络下拉同宽规则、密钥和API均未改。最终结果及图片见 [VALIDATION](VALIDATION.md)。

## 2026-10-03 · Swap标题与右侧网络标识对齐

按反馈把Solana网络图标/名称从Swap标题旁的混排移至AppScaffold右侧actions区域。标题恢复Swap/xStocks，链标识固定44px高度、24px图标，与标题同级字号并垂直居中；加载、空态、儿童限制、错误和正常状态全部复用。正常状态原右侧装饰swap图标由链标识替代，没有删掉可操作按钮。兑换/链限制/首次提示逻辑未改。

文件：swap_page.dart；已有solana_swap_scope_test首次提示用例补实际字体/390px截图，未新增/删除测试。3项Swap测试通过，两个文件静态检查通过，Android热更新2369ms成功，生产API调试继续保留。[截图](evidence/swap-network-header-aligned-20261003.png)已人工查看，范围见 [VALIDATION](VALIDATION.md)。

## 2026-10-03 · Arc Send沿用原Solana流程

修复两链不同交互：Arc不再在Send选择网络后直接展示一页表单。两链先显示正余额币种列表，Arc点击进入锁定币种填写页，再通过Next估费进入独立确认页，Cancel/返回保留填写内容，Send显式签名广播并展示发送中/结果。原Solana填写和确认的外观抽成共享send_widgets，业务逻辑不改；Arc沿用头像、扫码、金额/Max、可用余额、取消/下一步、确认摘要和结果样式。

新增EVM服务Max：实时余额、最高费用预留、6/18位精度向下取整、实际金额重新估费，费用不断变化/不足则失败；自定义代币全部余额另查USDC费。控制器计算前后检查解锁权限，不创建review或广播。扫码按所选网络识别，仅普通EVM收款地址/对应链的recipient URI；拒绝错误链及ERC-20合约transfer URI，原Solana提取行为保留。资产详情直达对应币种填写页；单次确认、重复发送与不确定提交保护保留。

新增15项自动测试（Max/控制器8、UI4、QR3），两份无资金集成脚本同步新空态。三个fixture截图已人工查看，逐项结果、生产Android联调与已知既有检查问题见 [VALIDATION](VALIDATION.md)，文件/安全边界见 [SEND_UX_PARITY](SEND_UX_PARITY.md)。没有后台、数据库、网络常量或钱包数据变更。

## 2026-10-03 · 所有下拉菜单与触发框同宽

根据最新反馈，取消224px独立菜单宽度。新增共享 `core/widgets/wallet_dropdown.dart`：展开菜单读取触发控件所在布局宽度，下方8px展开，统一白底、22px圆角、细边框及选中项暖色底/勾号。Send/Receive/活动网络选择保持完整页面内容宽；首页筛选框及菜单固定120px；Arc发送币种选择同卡片内容宽，保留忙碌禁用和原资产切换。首页菜单从 CheckedPopupMenuItem 改用 PopupMenuItem，两份集成测试匹配同步。

全客户端和设计组件库审查发现三处实际下拉入口，均迁入 WalletDropdown；设置/Swap 的底部面板及对话框保留。已有14项组件测试通过，无增删测试，补充三处展开截图；7个受影响文件静态分析通过，Android生产API调试热更新成功。未修改协议、后台、密钥、网络配置；完整Android/iOS重建、设备端到端和资金链路本轮未重跑。文件及证据见 [NETWORK_UI_AUDIT](NETWORK_UI_AUDIT.md)，实际结果见 [VALIDATION](VALIDATION.md)。

## 2026-10-03 · 完整宽选择框与独立紧凑菜单

根据进一步反馈，收发网络选择框应与页面内容等宽，仅展开菜单需要紧凑。共享 ChainNetworkSelector 改用 PopupMenuButton：完整宽度白色选择框、浮动 Network 标签和右侧箭头；下方8px间距展开224px圆角菜单，细边框、无重阴影，选中项暖色底与勾号。框宽与菜单宽独立，沿用本地图标和原回调/忙碌保护。

替代同日上一版将控件整体收窄至208px的实现。同步已有组件及两份集成测试改为查找 ChainNetworkSelector，避免依赖旧 DropdownButtonFormField；未新增测试。最终14项相关组件测试通过，三个修改文件静态分析通过；Android 热更新成功（515ms）。已查看展开与关闭截图，详情见 [NETWORK_UI_AUDIT](NETWORK_UI_AUDIT.md)。

## 2026-10-03 · 收发网络选择框比例

按反馈将共享 ChainNetworkSelector 从整行拉伸改为左对齐、208 logical pixels 的紧凑框，小屏受父布局约束自动缩小。Dropdown 菜单与框对齐，取消默认额外横向扩张，增加 20px 圆角、紧凑内边距与 280px 菜单高度上限；收发及共用活动页一起保持一致。链图标、名称、选择回调和忙碌禁用逻辑保留。

文件：`chain_widgets.dart`；已有接收切换测试增加菜单展开截图，无新增测试。最终14项组件测试通过、静态检查通过，Android 热更新成功。截图和范围见 [VALIDATION](VALIDATION.md)。

## 2026-09-29 · 全页面网络图标与交易历史链信息

统一 NetworkIcon/NetworkBadge，覆盖首页选中网络按钮、收发/活动下拉与标签、导入页、资产信息、确认/结果页及 Swap 币种选择。所有 Solana 收发历史与资产活动补链标识；Arc 活动列表/详情与通知按记录 chainId 显示，未知链保留标识不猜测。AppScaffold 支持带网络标识的标题。保留原链配置、协议与旧记录格式，无后台/数据库变更。

新增三项历史身份回归；20 项相关测试通过，静态分析通过，Android full debug 已构建安装启动。发现并修复新版 Flutter 对活动 ExpansionTile 背景层的断言，截图验证图标与历史展示。逐页覆盖、文件、截图和限制见 [NETWORK_UI_AUDIT](NETWORK_UI_AUDIT.md)。

## 2026-09-28 · Swap 仅支持 Solana 与首次提示

按产品要求，普通 Swap 标题明确 `Swap · Solana`，首次打开时提示 `ARC Swap coming soon` 及当前仅支持 Solana。点击 Got it/知道了后，以本机 SharedPreferences 非敏感标记保存确认状态，重开页面/应用不重复提示；退出弹窗而未确认或写入失败时下次再提示。不是每个钱包单独弹出，xStocks、锁定或儿童模式不弹此提示。

审查确认原 Swap 只从 Solana portfolio/balance 和既有 Solana catalog/search/quote/build 接口取数据，未合并 Arc 资产。`swap_repository.dart` 增加 32 字节 Base58 mint 校验，持仓、目录、搜索结果排除 EVM/无效地址；quote/build 同样先校验币对，防止绕过选择器调用。没有启用 Arc Swap、桥接或更改后台。

文件：`swap_page.dart`、`swap_repository.dart`、`app_settings_repository.dart`，新增 `test/features/swap/solana_swap_scope_test.dart`。新增三项覆盖混合数据过滤、错误链币对阻止请求及提示持久化；连同设置回归共 4 项通过，静态分析通过，Android 调试热更新成功。实际兑换资金闭环未重测，见 [VALIDATION](VALIDATION.md)。

## 2026-09-28 · 网络菜单图标

首页全部网络按钮将 `All` 文字替换为地球图标，保留下拉箭头；菜单内全部网络显示地球，Solana/Arc 名称前显示 ChainConfig 中的本地链图标，继续保留选中勾号与筛选行为。按钮提示包含当前网络，便于无障碍识别。修改 `portfolio_network_widgets.dart`，同步既有组件测试及两份 Arc 集成测试的 All 按钮匹配。未新增测试；11 项相关组件测试与文件静态分析通过。Android 调试更新和工具链说明见 [VALIDATION](VALIDATION.md)。

## 2026-09-28 · Solana 显示名称简化

按产品要求将网络选择、资产网络标签、收发与导入页显示的 `Solana Mainnet`（繁中 `Solana 主網`）统一为 `Solana`。修改共享显示名称与各语言 ARB，重新生成本地化代码，同步已有组件/集成测试的文案匹配；网络 ID、RPC、派生和存储没有变化。相关组件测试11项通过（既有菜单文本点击警告仍存在），未新增测试或重跑资金链路。Android full debug 构建、安装与启动通过，已更新专用模拟器并保留生产 API 调试连接；详细结果见 [VALIDATION](VALIDATION.md)。

## 2026-09-28 Android 连接生产 Arc 接口实测

设备：专用 `Benny_Arc_QA_API36` / emulator-5554 / Pixel 7 / API 36 ARM64；没有连接物理 Android 设备。客户端运行代码仍为 `460cd44`；此次只扩展集成测试和文档。后台生产 `1a2415c`（运行源与 `abab0b1` 相同），API `https://api.gobennyapp.com`，Arc mainnet 5042。

将现有真实设备测试按选中网络参数化，主网执行额外要求 `ARC_PRODUCTION_QA=true`、固定生产 API 和关闭直连 RPC。保留 `BENNY_EMULATOR_QA`、QA 根标记、未知钱包拒绝及无广播限制。实际运行 `flutter run -t integration_test/arc/arc_emulator_smoke_test.dart --flavor full`，STORE_MODE=full；无测试网/直接 RPC 开关、无 HTTP fixtures。构建58.5秒；设备用例51秒通过（一个 testWidgets + tearDown）。该测试文件静态分析通过，无问题。

覆盖真实 PIN/安全存储解锁、All/Solana/Arc 切换、Send→Receive→Swap 与链角标、生产 Arc 余额、原 Solana/派生 EVM 收款地址与复制、生产后台历史空态、错误地址/零数量/余额不足拒绝、USDC metadata 查询和导入去重。实际客户端流程可向生产写入此无资金 QA 钱包的公开账户绑定/自定义代币元数据；未上传恢复词/私钥、未签名或广播转账。页面证据：[生产主网首页](evidence/android-production-mainnet-20260928.png)。

测试后通过 detach 保留 QA 钱包，普通 lib/main.dart 的 full debug 构建41.1秒通过并成功安装启动，热重载连接保留，继续连接生产 API；不把集成测试 APK 留作普通应用。QA PIN为258025，仅限该无资金模拟器钱包，禁止注资。真机、资金闭环和推送没有验收；当前 debug 构建报告 Firebase runtime options 未配置，测试中通知关闭。


## 2026-09-28 生产只读验收完成

后台运行版本 `abab0b1` 已由 GitHub main 自动部署，Railway deployment `0781842c-3366-4abf-b390-ef566a6f40f9` 为 Active。生产主网 5042、Supabase 读取、Arc USDC 精度/余额/估费/日志/回执查询及原 Solana 登录和余额读取均通过；索引已开启，08:05:23.293Z 成功完成一轮，无 lastError。未注册测试 EVM 账户、未广播交易、未使用资金；索引健康不代表大账户历史回填或实际 FCM 送达已验收。

前后端 `arc` 均已快进合并到 `main` 并保留开发分支。手机运行代码仍为 `460cd44`，本次仅补充文档，未重建或发布商店包。可以开始专用 Android 真机无资金联调；资金闭环、真机通知和存量版本原地升级按测试计划继续。后台配置默认开启 API/索引，主网节点有默认值，既有秘密仍在 Railway；无需另外上传 `.env` 文件。

详细 SQL 版本、发布顺序、线上结果与未验收项目：[后台发布记录](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_RELEASE_2026_09_27.md)。


## 2026-09-27 自动发布与数据库增量

按现有 GitHub main → Railway 自动发布流程交付，不更换服务或部署分支。后台提交 `4b24dab` 已快进合并 main，数据库 SQL 已在 Supabase 执行（远程版本 `20260927142033`，本地源文件 `20260926094915_arc_multichain_services.sql`）；新增 6 表/4 函数，保留原表和钱包数据。生产发布和只读验证的最终状态见 [后台发布记录](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_RELEASE_2026_09_27.md)。

Arc 默认主网 5042，节点/功能开关来自后台版本化配置，既有服务密钥继续由 Railway 管理。手机默认连接 `https://api.gobennyapp.com`，不需要打开测试网或直接 RPC 开关。本地 Circle 主网复查已返回 HTTP 200 / 5042，不再将 09-26 的 403 当成当前结果。

本次手机仅更新文档，没有修改运行代码、密钥存储或 Android/iOS 构建配置。最新既有证据仍为 88 项 Flutter 测试、静态检查、Android full/liteStore debug 和 iOS unsigned debug 通过；没有借此声称受控资金收发、FCM、真机升级或签名发布通过。


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
