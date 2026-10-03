# 验证记录与待验收事项

## 2026-10-03 首页网络筛选与余额避免重叠（最新）

- 基线c994139。首页卡片取消金额/网络控件Stack：Total Balance标签与筛选在独立顶部行，金额在下行完整内容宽度居中缩放。All/Solana/Arc下拉继续与按钮同宽；筛选/总额逻辑不变。
- `flutter test --no-pub test/features/multichain/widgets_test.dart`：最终18项通过，无新增/删除测试。将已有首页简化Column fixture换成真实PortfolioPage，覆盖默认两链、切链资产列表与返回；截图包含三种筛选及320px/字体1.25/123456789.12长金额。测试辅助覆写空DeFi、未读数、更新提示，避免后台请求/计时器；首轮仅金额期望的千位分隔格式写错，按实际Formatter修正后全文件通过。
- 源码portfolio_page.dart及修改组件测试分别静态分析No issues found；`git diff --check`通过。
- 已人工查看真实页面组件fixture：[All](evidence/home-balance-all-20261003.png)、[Solana](evidence/home-balance-solana-20261003.png)、[Arc](evidence/home-balance-arc-20261003.png)、[窄屏/长余额](evidence/home-balance-narrow-large-text-20261003.png)。按钮背景与余额分区，无覆盖/余额裁切。Arc Testnet/100USDC及长总额为公开测试数据，不代表生产持仓；320px/放大字体下既有顶部品牌与资产行会截短，本轮余额布局没有扩大该修改范围。
- Android普通main.dart生产API调试热更新559ms成功，连接保留；本轮无完整Android/iOS重建、设备联调或资金操作。UI保留PIN会话锁定规则，不自动解锁。先前全量本地化/构建缓存检查问题没有重测或宣称消除。

## 2026-10-03 Swap顶部网络标识对齐（最新）

- Swap/xStocks标题左侧、Solana标识右侧，同一顶栏垂直居中；标识44px高、24px图标、字号采用titleLarge，所有主页面状态统一。源码及兑换协议/范围无其他变化。
- `flutter test --no-pub test/features/swap/solana_swap_scope_test.dart`：最终3项通过，无新增/删除测试。现有首次提示用例加载真实字体、390×844 viewport，补顶部对齐截图；初版截图使用测试默认字形，补字体后重跑通过。
- `flutter analyze --no-pub lib/features/swap/presentation/pages/swap_page.dart test/features/swap/solana_swap_scope_test.dart`：No issues found。
- [字体加载后的组件截图](evidence/swap-network-header-aligned-20261003.png)人工查看：标题与图标/网络名居中对齐，右侧清晰，无裁切。截图是加载状态fixture；正常/空态/错误等使用同一标识构建方法，未逐状态真机截图。
- Android普通main.dart生产API full debug热更新2369ms成功，调试连接保留；本轮未重新完整构建Android/iOS、未跑设备QA或兑换资金。上一轮记录的全量本地化/构建缓存问题不因本轮局部测试通过而消除。

## 2026-10-03 Send交互按原Solana统一（最新）

代码基线 `a9c9fb3`；本轮Send对齐改动，提交可从 [CHANGELOG](CHANGELOG.md) / Git历史追溯。没有后台/数据库/密钥/链常量改动。

- 相关组件18项、EVM/Solana adapter与转账控制器38项、QR decoder3项均通过；新增15项，已有流程测试重写但未删除其他测试。公开fixture验证选币→填写→确认→显式Send、取消保留、金额/地址拒绝、单次广播/忙碌返回、Max费用精度/余额/权限、QR错误链及合约URI拒绝。
- 完整 `flutter test --no-pub`：108通过、1失败。唯一失败为已有Swap提示未本地化字面量 `ARC Swap coming soon`；已确认相同字面量存在于基线提交，原文件未修改。不宣称全量通过，截图/业务回归均通过。
- `flutter analyze --no-pub lib test integration_test`：No issues found。完整 `flutter analyze --no-pub`另报75项，仅来自忽略的 `build/ios/SourcePackages/firebase_messaging-16.2.2`第三方示例/测试缓存，含mockito缺失和API不匹配；应用源码范围通过，本轮未修改分析配置或第三方缓存来隐藏报告。
- 三张390px截图人工查看：[Arc币种列表](evidence/arc-send-assets-parity-20261003.png)、[填写页](evidence/arc-send-compose-parity-20261003.png)、[确认页](evidence/arc-send-review-parity-20261003.png)。截图公开无资金Arc Testnet fixture，不代表真实资金链路或生产资产余额。
- Android专用 `Benny_Arc_QA_API36` / emulator-5554，full debug生产API：新路由热重启7879ms后，又完整构建设备集成APK21.1s、安装7.5s；`integration_test/arc/arc_emulator_smoke_test.dart`105s通过（1个testWidgets + tearDownAll，runner +2）。使用 `BENNY_EMULATOR_QA=true`、`ARC_PRODUCTION_QA=true`、STORE_MODE=full、API_BASE_URL=https://api.gobennyapp.com，主网5042，未打开测试网/直连RPC、无HTTP fixtures。
- 设备实际覆盖QA钱包PIN/真实安全存储解锁、All/Solana/Arc、收款二维码/复制/历史、Arc与Solana零持仓Send同空态/无表单/切链、USDC metadata/import去重。仅无资金QA账户，可发生既有公开账户绑定和导入元数据写入；未导出秘密，未签名/广播交易。原正余额发送用组件fixture验收，禁止给此QA钱包注资。
- 测试APK之后已恢复普通 `lib/main.dart` full debug：11.3s构建、5.2s安装、135ms文件同步，启动成功且调试连接保留，仍接生产API。工具链自动增加的4行Gradle兼容属性恢复，不混入提交。
- 本轮未重跑另一份fixture设备测试 `arc_backend_ui_test.dart`、iOS、物理手机/摄像头QR、受控资金收发及推送。Firebase runtime options未配置、310项zh翻译缺失/旧构建版本支持提示仍存在。详细页面/API/待验收范围见 [SEND_UX_PARITY](SEND_UX_PARITY.md)，测试注册清单已刷新 [AUTOMATED_TESTS](AUTOMATED_TESTS.md)。

## 2026-10-03 所有下拉菜单同宽（最新）

- 客户端全 lib 与设计组件库静态搜索审查：三处下拉入口共用 WalletDropdown；网络字段/币种字段按页面/卡片内容宽度，首页筛选框和菜单120px。菜单在框下方8px，统一圆角/细边框/选中底色与勾号。
- `flutter test --no-pub test/features/multichain/widgets_test.dart`：最终14项通过，无新增/移除测试；已有首页/接收/发送用例补展开菜单截图，资产选择匹配同步新组件。覆盖网络切换、表单清空、收款地址/二维码、发送确认与显式广播、锁定/儿童限制和交易所属链标识。
- `flutter analyze --no-pub lib/core/widgets/wallet_dropdown.dart lib/features/multichain/presentation/chain_widgets.dart lib/features/multichain/presentation/portfolio_network_widgets.dart lib/features/multichain/presentation/network_send_page.dart integration_test/arc/arc_backend_ui_test.dart integration_test/arc/arc_emulator_smoke_test.dart test/features/multichain/widgets_test.dart`：No issues found。设备集成测试仅同步匹配，未重新运行。
- 三张390px组件截图人工查看，无文字/图标溢出，菜单与框左右对齐：[接收](evidence/receive-matched-width-menu-20261003.png)、[首页菜单fixture](evidence/home-matched-width-menu-20261003.png)、[发送币种](evidence/send-asset-matched-width-menu-20261003.png)。公开无资金Arc Testnet fixture；运行app仍使用生产主网配置。
- Android普通生产API full debug 热更新成功，调试连接保留；本轮无完整Android重建/安装、iOS构建、资金交易或后台变更。

## 2026-10-03 选择框与菜单分别布局（上一版）

- 完整宽选择框 + 224px紧凑菜单，PopupMenuPosition.under + 8px间距；选中项图标/名称/暖色底/勾号，细边框无重阴影。
- `flutter test --no-pub test/features/multichain/widgets_test.dart`：最终14项通过，无新增测试。首次替换集成测试 finder 静态检查发现缺少组件 import，补齐后通过。
- `dart analyze lib/features/multichain/presentation/chain_widgets.dart integration_test/arc/arc_backend_ui_test.dart integration_test/arc/arc_emulator_smoke_test.dart`：No issues found；两份设备集成测试仅同步 finder，本轮未重跑生产资金或端到端链路。
- Android普通生产 API full debug 热更新成功（515ms），调试连接保留，无重新构建/安装或iOS验证。
- 已人工查看[展开菜单](evidence/receive-fullwidth-control-menu-20261003.png)和[关闭选择框](evidence/receive-fullwidth-control-20261003.png)，宽度、图标、选中项无溢出。截图为公开 Arc Testnet 组件fixture，模拟器仍连接既有主网配置。

## 2026-10-03 网络选择框宽度

- `flutter test --no-pub test/features/multichain/widgets_test.dart`：最终14项通过，包含 Send/Receive 切换、地址/二维码一致性、表单清空、网络历史标识；既有菜单文字点击警告保留。对齐菜单时一次构造函数参数错误导致编译失败，修正后重新全文件通过。
- `dart analyze lib/features/multichain/presentation/chain_widgets.dart`：No issues found。
- Android 普通 full debug 热更新成功（35 个库 / 2,117 ms）；既有生产 API 会话保留，本轮无重新安装/完整构建、无实际资金操作。
- [紧凑网络菜单截图](evidence/receive-network-menu-compact-20261003.png)：390px 组件布局，菜单宽度208px，图标/名称无溢出，已人工查看。Arc Testnet 是组件 fixture，运行 app 主网配置未变。

## 2026-09-29 全页面网络标识

- `flutter test --no-pub test/features/multichain/widgets_test.dart test/features/swap/solana_swap_scope_test.dart test/features/notifications/chain_notification_test.dart`：20 项通过。初次运行发现活动卡片 Material 背景断言，修复后全部通过；既有菜单文本点击警告仍存在。
- `dart analyze lib test/features/multichain/widgets_test.dart test/features/swap/solana_swap_scope_test.dart`：No issues found。
- 截图辅助先等待本地图片解码；Solana 历史单项复跑通过，两个历史截图已人工查看，无文字溢出。
- Android full debug / 普通 main.dart：23.5 秒构建、721 ms 安装并成功启动，专用 Benny_Arc_QA_API36 调试连接保留，生产 API 未变。旧 Gradle/AGP/Kotlin 支持提示与 Firebase 未配置提示仍存在；未修改构建版本。
- 后台、资金收发、iOS、完整真机逐页验收未重测。[逐页检查清单与截图](NETWORK_UI_AUDIT.md)。

## 2026-09-28 Swap 范围与首次提示

- Flutter 3.47.5 / Dart 3.13.4；`flutter test --no-pub test/features/swap/solana_swap_scope_test.dart test/features/settings/app_settings_repository_test.dart`：4 项通过。覆盖同名 USDC 的 Solana/EVM 持仓与目录/搜索隔离、EVM 币对在 quote/build 请求前拒绝、首次确认及页面重建不重复提示、原设置清理保留语言。
- `dart analyze lib/features/swap lib/features/settings/data/app_settings_repository.dart test/features/swap/solana_swap_scope_test.dart`：No issues found。
- 普通 Android full debug 在 Benny_Arc_QA_API36 热更新成功（72 个库 / 4,167 ms），现有生产 API 调试会话保留。没有运行真实兑换或签名/广播，后台与钱包密钥未变；本轮未重新完整构建 Android/iOS。
- 人工复核步骤：首次进入 Swap → 查看提示及 Solana 标题 → 确认 → 返回再次进入/重启后进入应不再提示；分别打开支付/接收币种搜索，同名 USDC 仅 Solana 可用。提示 UI 与持久化已由组件测试覆盖，真机人工复核待执行。

## 2026-09-28 网络菜单图标

- Android full debug 构建通过（128.2 秒），安装通过（12.8 秒），专用 Benny_Arc_QA_API36 启动并连接调试器；普通 main.dart，继续使用生产 API https://api.gobennyapp.com。
- `flutter test --no-pub test/features/multichain/widgets_test.dart`：11 项通过；复用原首页筛选测试，All 匹配改为地球图标。两份 Arc 集成测试仅同步匹配，本轮未重跑生产端到端测试。
- `dart analyze lib/features/multichain/presentation/portfolio_network_widgets.dart`：No issues found。
- 本机 SDK 在调试期间变为 Flutter 3.47.5 / Dart 3.13.4，旧会话断开，首次测试因 Flutter 包语言版本缓存过旧编译失败；重新 pub get 后通过。新 SDK 自动解析的 5 项 SDK 依赖和 Gradle 迁移属于本地验证环境，恢复原锁文件和 Gradle 属性，未混入本次 UI 提交。
- 未重跑 iOS、全量测试或资金收发；原 310 项 zh 翻译提示仍存在。

## 2026-09-28 Solana 显示名称简化

网络菜单、资产网络标签、收发与导入页统一显示 `Solana`；共享显示常量、各语言 ARB/生成文件与已有测试匹配同步更新。网络 ID、RPC、派生和钱包存储未变。

- `flutter test --no-pub test/features/multichain/widgets_test.dart`：11 项通过，保留既有菜单文本点击警告；集成测试只同步文案，本轮未重跑。
- `flutter pub get`：通过，锁文件无变化。
- Android full debug / 普通 `lib/main.dart`：构建通过（230.7 秒），安装通过（4.4 秒），专用 `Benny_Arc_QA_API36` 模拟器启动成功；继续连接 `https://api.gobennyapp.com`，保留调试连接和原 QA 钱包。
- 文案搜索确认 lib/packages 无旧显示名称；内部 `solana-mainnet` 标识保持。`git diff --check` 通过。
- 本轮未重跑 iOS、生产资金链路或全量测试；现有中文翻译缺失提示仍待补齐。

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


## 2026-09-27 存量用户兼容复核

运行代码仍为客户端 `460cd44` / 后台 `283f8a5`；本次仅补充测试和文档，没有修改运行逻辑。完整审查与真机前置条件：[EXISTING_USER_ANDROID](EXISTING_USER_ANDROID.md)。

- `flutter test --no-pub --reporter expanded`：**88 项通过**（约 7 秒），含旧密文不变/Arc 地址稳定/Solana 地址保持的增强断言、2 项 Arc 故障/不支持时的 Solana 页面回归。
- `flutter analyze --no-pub`：PASS，No issues found。
- 后台 `npm test`：**23 项通过**；新增 Arc 插件故障/链头与旧路由隔离测试。测试文件 TypeScript strict 检查通过。
- 旧钱包仓库、钱包 controller、加密/存储/安全及 Android 目录对照 `08cbed3` 无代码变化。Solana 服务增加精确费用/适配器辅助方法，原费用总额算法与发送入口保留；解锁页面有 mounted 生命周期修复。
- 原 Android/iOS 构建证据继续适用于未变更的运行代码，本次未重复构建。未部署生产、未安装个人真机、未用真实用户数据或资金；历史生产版本覆盖升级与硬件生物识别仍需设备验收。

## 当前：主网后台对齐（2026-09-26 实测，09-27 收尾复核）

客户端基线 `6f8b623`，后台基线 `db53c5a`（实现提交 `283f8a5`），各自 `arc` 分支的本轮提交。精确运行代码对应 [客户端 blob 清单](evidence/mainnet-source-manifest.txt) 和 [后台 blob 清单](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/arc-source-manifest.txt)；Git 提交和 CHANGELOG 保存完整差异。以下为实际执行结果摘要，未把旧测试网结果移植成主网证据。

| 检查 | 日期 | 实际结果及范围 |
|---|---|---|
| `flutter pub get` | 09-26 | PASS；未整体升级 Flutter 依赖 |
| `flutter analyze --no-pub` | 09-26 | PASS，No issues found |
| `flutter test --no-pub --reporter expanded` | 09-26 | **86 项通过**，原 72 项保留；新增后台客户端 8、估值 3、通知 3 |
| Android `arc_backend_ui_test.dart` / full / STORE_MODE=full | 09-26 | PASS，43 秒；真实存储/PIN与共用 UI，HTTP 使用 fixture，不代表已部署后台 |
| 同一主网 fixture / liteStore / STORE_MODE=lite | 09-26 | PASS，40 秒；独立 package、随机无资金 QA 钱包 |
| Android `arc_emulator_smoke_test.dart` / full | 09-26 | PASS，45 秒；显式测试网+直接 RPC，真实公共测试网只读回归，未广播 |
| 普通 Android full debug / STORE_MODE=full | 09-27 | PASS，27.2 秒；默认主网、普通 main.dart，无测试 harness |
| 普通 Android liteStore debug / STORE_MODE=lite | 09-27 | PASS，31.7 秒；默认主网、普通 main.dart |
| `flutter build ios --debug --no-codesign --no-pub -v` | 09-26 | **PASS**，生成 `build/ios/iphoneos/Runner.app`；Xcode 27.0 / 27A266a |
| 后台 `npm run build` | 09-26、09-27 | PASS |
| 后台 `npm test` | 09-26、09-27 | **22 项通过**：17 服务/路由/索引/通知 + 5 PGlite SQL/权限/事务 |
| 后台测试 TypeScript strict 检查 | 09-26 | PASS |
| 后台 `npm audit --omit=dev` | 09-26、09-27 | **0 vulnerabilities**；全部开发依赖另有 4 个 advisory，未强制升级工具链 |
| 官方 Circle、dRPC 主网 `eth_chainId` | 09-26 | **BLOCKED：HTTP 403**；两次只读复核，没有规避访问限制 |
| 远程迁移/部署、真实 FCM、受控资金主网闭环 | — | **NOT RUN**，没有线上成功或转账 hash 证据 |

模拟器：专用 `Benny_Arc_QA_API36` / Pixel 7 / API 36 / ARM64，Flutter 3.41.6、Dart 3.11.4。Android 构建和集成测试均关闭 app updates、Seeker Vault；集成另启用 `BENNY_EMULATOR_QA=true`。QA PIN `258025` 只适用于自动创建的可丢弃无资金钱包，禁止注资。未读取客户钱包、未改写现有加密根、未发送真实资产。HTTP fixture 验证请求合同与页面交互；PGlite 验证数据库语义；二者都不代替真实服务联调。

iOS 最初失败原因为缺少被 Git 忽略的 Firebase plist。新增构建脚本仅允许 Debug 无该文件；Release/Profile 仍要求真实配置，不生成假凭据。最终无签名设备构建成功。Xcode 仍报告 CoreSimulator/CoreDevice 组件版本警告，未验证 iOS 模拟器/物理设备/签名发布/推送，不能将这些写为通过。旧的 Xcode 许可阻塞记录保留在下面历史段落。

### 当前发布前必须补齐

- 在 staging 应用新增迁移并验证 hosted Supabase/PostgREST、服务角色和跨钱包隔离；部署 Arc 后台后检查配置/健康接口，保留原 Solana 回归证据。
- 在部署环境解决主网 RPC 403/提供商访问，确认 chain ID、余额、估费、收据和日志；再使用私有受控钱包验收真实 USDC/ERC-20 收发及费用，不使用公开 QA 钱包。
- 验证多设备恢复、真实 FCM、分页长期历史、索引追赶延迟/多进程并发和流量配额。功能已有代码与本地测试，容量及端到端仍待验收。
- 验证 iOS 模拟器/真机、Android 生物识别硬件、历史生产格式升级与签名 release。当前 iOS/Android debug 编译通过不等于双平台可发布。
- BENNY 主网合约尚未提供；必须由发行方核实后配置/导入，不能编造。未知结果广播保留 hash/nonce，当前不提供替换或取消，需运营排查，禁止自动重发。
- 原测试矩阵中剩余本地化、无障碍、儿童模式全变体和真实 Solana 资金回归继续有效。Arc Swap/Bridge 不在此次范围。

本轮结论：**前后端基础能力已实现并通过上述本地验证；未完成生产上线及真实资金/设备验收。** 以下均为历史记录，不能覆盖本节状态。

## 历史 Android 原生回归增补（2026-09-25）

运行时代码仍为 `67da717`（`c7b3c2d` 仅文档整理）；本次只增强集成测试与文档。
可复现的集成测试文件Git blob：`de8270086a06220384fbf9db99072d4b54b0b37b`，即本次提交的 `arc_emulator_smoke_test.dart`。

| 配置 | 结果 | 证据与范围 |
| --- | --- | --- |
| `full` + `STORE_MODE=full` | PASS，73秒测试执行时间 | [runner摘要](evidence/android-full-smoke.txt)；Send→Receive→Swap顺序、角标、两链过滤、Arc-only隐藏Swap、真实安全存储/PIN/地址/历史/错误输入/导入USDC去重 |
| `liteStore` + `STORE_MODE=lite` | PASS，39秒测试执行时间 | [runner摘要](evidence/android-lite-smoke.txt)；相同收发路径，显式验证Swap隐藏 |
| 增强测试源码的静态分析 | PASS，10.8秒 | [日志](evidence/android-acceptance-analysis.txt) |

运行环境同下：Pixel7 API36 ARM64专用模拟器。使用 `flutter run -t integration_test/arc/arc_emulator_smoke_test.dart` 保留QA数据；`BENNY_EMULATOR_QA=true`、app updates与Seeker Vault关闭。full和liteStore有不同包ID/各自随机QA根。没有读取客户钱包、签名或广播。Runner的 `+2` 包含测试与tearDown，不是新增两条业务用例；现有72条本地测试数不变，本次未重复跑未改动的单元套件。

普通APK后续构建：[构建摘要](evidence/android-flavor-builds.txt)。`liteSeeker` + STORE_MODE=lite（Seeker Vault默认开启）43.9秒通过；`full` + STORE_MODE=full 18.3秒通过；`liteStore` + STORE_MODE=full（恢复原先带Swap的界面调试配置）39.6秒通过。full/liteStore使用原地安装替换测试harness，保留各自QA数据；liteSeeker只证明编译成功，未安装/验证Seeker硬件。未构建签名release。普通liteStore包冷启动再次要求PIN，解锁后All首页、按钮顺序和链角标人工复核正常：[恢复后的首页](evidence/android-restored-home.png)。

这补齐了最新界面改动后的原生脚本复测，不代表93项测试计划全部完成。FE-03/04只覆盖脚本列出的变体；儿童模式、离线重启、物理硬件、有资金收发与后台仍有独立验收项。

## 历史功能代码：67da717（2026-09-25）

代码范围：`08cbed3..67da717`；之后的 `arc` 分支整理只改文档与证据，不改变运行代码。完整历史见 [CHANGELOG.md](CHANGELOG.md)。

| 检查 | 日期/代码 | 结果 | 证据/范围 |
| --- | --- | --- | --- |
| flutter pub get | 09-25 / 67da717 | PASS | 文档发布前重新执行，依赖解析成功 |
| flutter analyze --no-pub | 09-25 / 67da717 | PASS | 6.1秒，No issues found；[日志](evidence/analysis.txt) |
| flutter test --no-pub --reporter expanded | 09-25 / 67da717 | PASS | 8秒，**72项通过**；[脱敏日志](evidence/unit-widget-tests.txt)、[72条目录](AUTOMATED_TESTS.md) |
| Android liteStore debug build | 09-25 / 67da717对应代码 | PASS | 13.3秒；[日志](evidence/android-build.txt)；以下列出的UI调试flags构建 |
| 普通APK原地安装、PIN解锁、首页检查 | 09-25 / 67da717对应代码 | PASS（人工） | Send→Receive→Swap和Solana/Arc角标；[截图](evidence/home-network-badges.png) |
| 当前版本全套后台服务端测试 | — | NOT RUN | 本仓库无后台；客户端mock结果不替代服务端验收 |
| 当前版本iOS构建 | — | BLOCKED/未复测 | 上次构建因Xcode许可/初始化失败；下面记录历史结果 |
| 当前版本真实测试网资金闭环 | — | NOT RUN | 没有转账hash/资金结算证据，未广播 |

环境：macOS，Flutter3.41.6，Dart3.11.4；Android Pixel7/API36/ARM64专用模拟器，非物理安全硬件测试。分析/构建通过 `DEVELOPER_DIR=/Library/Developer/CommandLineTools` 选择已安装SDK；全量测试还使用临时本机xcrun wrapper处理native hooks的SDK选择。新开发环境优先正常初始化Xcode，参见 [开发指南](DEVELOPMENT.md)。

Android UI调试构建命令：

```sh
flutter build apk --debug --flavor liteStore --no-pub \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false \
  --dart-define=FEATURE_SEEKER_VAULT_ENABLED=false
```

没有显式 `STORE_MODE=lite`，默认功能模式为full，因此首页显示Solana Swap。不能把此结果用于宣称商店Lite功能配置已验收。构建产物 `apps/wallet_client_flutter/build/app/outputs/flutter-apk/app-litestore-debug.apk` 为本地文件，不随Git提交，也没有发布GitHub Release或应用商店。

## 保留的阶段验证（不冒充最新代码端到端复测）

| 日期/提交 | 已执行结果 | 限定 |
| --- | --- | --- |
| 09-19 / ba322ad | 基础68项测试、分析、Android构建、只读Arc RPC通过 | 初版额外网络入口，后来已统一；没有资金转账 |
| 09-19 / ba322ad | iOS `flutter build ios --debug --no-codesign --no-pub` exit69 | Xcode许可未接受/first-launch与CocoaPods需处理；无iOS成功记录 |
| 09-24 / 4133153 | 70项测试，真实Android secure-storage/PIN/地址/历史/导币集成通过43秒 | 专用无资金钱包；不验证硬件生物识别或签名广播 |
| 09-24 / 4133153 | 公共RPC100块分段、1000块历史只读检查通过 | 250块遭HTTP400/code35；未自动扩大请求；广播0 |
| 09-25 / 9402403对应代码 | 72项测试；统一界面Android集成通过46秒 | All/单链过滤、地址/历史、输入校验、导币去重；最后微小布局/角标修改后未重跑该整套原生脚本 |
| 09-25 / 9402403对应代码 | 普通APK Send/Receive/详情、网络选择人工检查 | [Send](evidence/shared-send.png)、[Receive](evidence/shared-receive.png)；这些截图早于角标/顺序微调 |
| 09-25 / 67da717对应代码 | 9项相关组件测试、分析、普通APK UI人工检查 | 随后文档发布前全量72项重新通过 |

原详细过程与旧计数保留在 [MILESTONE_2_ARC.md](../../MILESTONE_2_ARC.md) 各日期段落。68→70→72是不同版本的增长，不是相互矛盾的同一次测试结果。此次文档整理没有再次执行链上写入、后台部署、数据库迁移或iOS环境变更。

## 文档发布检查（2026-09-25）

11份Markdown、205个仓库相对链接、代码围栏、93个唯一测试计划ID检查通过；现有自动化目录核对到72条注册用例。文档/文本证据检查未发现所扫描的常见凭据格式；此有限检查不等于完整安全审计。截图只包含专用QA钱包的公开界面。

## 2026-09-25 当时待补齐清单（最新状态见文首）

| 项目 | 状态/原因 | 下一步与测试ID |
| --- | --- | --- |
| 独立私有测试钱包实际USDC/ERC20收发、费用/回执 | 未注资，无链上闭环证据 | E2E-01…08、CH-16/17；保留hash和余额核对 |
| iOS编译、模拟器、真机 | 开发环境阻塞 | PLAT-03/04；初始化Xcode/CocoaPods再运行 |
| Android/iOS生物识别与安全存储升级 | 模拟器不能证明硬件安全；历史实现有绑定限制 | SEC-02…07，在受控设备/旧版本测试 |
| 服务端完整回归 | 没有该仓库源代码/部署测试上下文 | BE-01…18，记录server commit/staging环境 |
| 发布flavor/签名/release配置 | 三个flavor的debug构建已过；release签名/商店配置未验收 | PLAT-02/07；真机和发布配置继续验证 |
| 完整本地化/无障碍/屏幕矩阵 | 有130%字体历史检查，未覆盖全部场景 | FE-29/30；既有中文仍有未翻译消息 |
| 生产存储格式全面安全迁移 | 仅当前仓库fixture与独立向量通过 | SEC-02；不改写客户数据，不宣称所有历史记录已验证 |
| 全历史/跨链fiat/Arc通知 | 未实现，当前仅近期RPC历史，无Arc fiat feed | 下一阶段需求；当前UI必须如实表达边界 |

## 验收结论

**可继续Android测试与开发；不是完整MVP、主网或双平台发布完成。** 当前安全边界和未完成项不得被以后AI删除以“简化文档”。没有客户秘密或资金用于本轮验证。

## 后续结果填写模板

```text
Date:
Code commit (not just branch name):
Platform / device / flavor / STORE_MODE / flags:
Backend commit & environment / RPC chain ID:
Case IDs:
Commands / steps:
Result: PASS / FAIL / BLOCKED / NOT RUN
Evidence (repository-relative sanitized logs/screenshots, public testnet hash):
Limitations / issue / next action:
```
