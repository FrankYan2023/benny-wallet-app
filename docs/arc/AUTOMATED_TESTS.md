# 现有自动化测试目录

## 当前快照：2026-10-03 Arc加载与流畅度优化

客户端基线`66fc383`加本轮优化，`test/`注册**125项**（上一快照109项 + 新增16项），没有删除旧测试；设备集成脚本3项仍单独执行。完整套件实际结果**124通过、1失败**，唯一失败仍为既有Swap提示本地化检查。源码/测试/集成入口范围静态分析通过；本轮未重跑设备集成脚本/iOS/资金测试。后台28项测试通过，其中新增5项详见[后台性能记录](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_PERFORMANCE_2026_10_03.md)。执行记录见 [VALIDATION](VALIDATION.md)。

以下列出16项新增注册；其余109项名称保留在上一快照中。发送组件已有2项仅调整等待真实isolate完成的方式，广播次数/忙碌断言保持。

### `test/core/chains/evm_key_service_test.dart`（新增5项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/evm_key_service_test.dart)

- background EVM derivation preserves address and rejects invalid roots
- background personal signing matches independent ethers vector
- background personal signing rejects a mismatched account
- background personal signing snapshots mutable message bytes
- background EVM derivation keeps the main event loop responsive

### `test/core/chains/solana_message_signer_test.dart`（新增2项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/solana_message_signer_test.dart)

- background Solana authentication preserves legacy owner and main event loop
- background Solana authentication rejects another owner or derivation

### `test/features/multichain/loading_test.dart`（新增5项）

[源文件](../../apps/wallet_client_flutter/test/features/multichain/loading_test.dart)

- public EVM address is derived once per unlock, not once per caller
- portfolio skips redundant tokens read and survives a brief network switch
- local-only custom tokens still synchronize and appear in portfolio
- an owner change hides prior assets even if the new request fails
- refresh retains rows and shows stale failure until retry succeeds

### `test/core/chains/chain_backend_client_test.dart`（新增4项，现共12项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/chain_backend_client_test.dart)

- transient read retries once with fresh headers and identical RPC payload
- reads honor short Retry-After and never retry long throttles or permanent errors
- token import and account verification writes are never retried
- a wallet switch during retry delay stops before the second request

## 上一快照：2026-10-03 发送交互对齐

提取自 `a9c9fb3` 加本轮 Send 交互改动的工作树；最终提交号见 [CHANGELOG](CHANGELOG.md) / [VALIDATION](VALIDATION.md)。本节名称逐个来自当前源文件的 `test` / `testWidgets` 注册，路径相对仓库根；注册用例、测试计划 ID、assert 数量和 runner 总数各自独立。旧快照保留在本文末尾，不将旧通过结果覆盖为本轮结果。

当前 `test/` 注册 **109 项**；本轮新增 **15 项**：EVM Max 6 项、控制器 Max 权限 2 项、发送组件 4 项、QR 解析 3 项。另有设备集成脚本 3 个，每个注册 1 项，单独执行，不计入109项。

实际执行结果（2026-10-03）：

- 发送/多链组件：18项通过；EVM + Solana adapter + transfer controller：38项通过；QR解析：3项通过。
- 完整 `flutter test --no-pub`：**108通过、1失败**。失败为既有 `localization coverage presentation pages do not contain unlocalized visible literals`，指出未改动的 Swap 提示字面量 `ARC Swap coming soon`；当前不能宣称全量套件通过。
- `flutter analyze --no-pub lib test integration_test`：通过。全项目分析另报75项，位于忽略的 `build/ios/SourcePackages` 第三方示例缓存；记录范围不同，不将全项目结果写成通过。
- Android普通生产API调试热重启成功（7879ms）；随后专用模拟器生产主网5042无资金集成测试通过（1项testWidgets + tearDownAll，runner +2，105秒），API为`https://api.gobennyapp.com`，无fixture/直接RPC替代。恢复普通main.dart构建11.3秒、安装5.2秒，调试连接保留。本轮未重跑iOS构建、真机、实际发送/Swap或资金测试。

发送流程、用例分工和待验收边界见 [SEND_UX_PARITY](SEND_UX_PARITY.md)。执行方法见 [DEVELOPMENT](DEVELOPMENT.md)。

### `test/core/chains/chain_backend_client_test.dart`（8项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/chain_backend_client_test.dart)

- mainnet is default and has no testnet gas-floor assumption
- authentication proof rejects arbitrary signing, changed owner, network and expiry
- backend uses only API host, auth header and expected chain; verifies chain before reads
- wrong backend network prevents broadcast
- ambiguous send is attempted once and never fails over
- wallet switch while awaiting authentication prevents requests
- asset decoding retains exact balance and optional quote
- history keeps distinct logs but replaces duplicate transaction summary

### `test/core/chains/evm_adapter_test.dart`（23项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart)

- BIP44 derivation matches independent Ethereum vector
- EVM address rejects bad EIP55 mixed case, zero and missing prefix
- native/ERC20 USDC aliases deduplicate and preserve fee dust separately
- custom ERC20 metadata, exact balance and ABI transfer encoding
- invalid metadata decimals, malformed ABI and non-contract import fail
- fee estimation applies Arc floor and reserves combined USDC spend
- custom token needs both token balance and USDC fee balance
- USDC Max reserves maximum native fee and preserves 6/18 precision
- native 18-decimal Max preserves balances beyond double precision
- USDC Max requotes the actual amount when gas requirements rise
- ERC20 Max uses fresh full token balance with separate native fee
- USDC Max rejects insufficient fee balance and wrong network
- USDC Max fails safely when fees never stabilize
- typed EIP1559 envelope and hash match independent ethers vector
- network mismatch, wrong root mnemonic, stale nonce prevent signing
- altered reviewed amount or signed envelope cannot broadcast
- concurrent duplicate broadcast and ambiguous response never resubmit
- Arc receipt pending, success and reverted failure are distinguished
- other EVM networks await finalized block rather than Arc finality
- bounded history deduplicates incoming/outgoing logs and excludes USDC ERC20 alias
- tracked unknown submissions never leak to a different root wallet
- EIP191 and EIP712 match independent ethers signatures
- future signing intent decodes transfers and unlimited approvals, blocks blind review

### `test/core/chains/evm_rpc_test.dart`（4项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/evm_rpc_test.dart)

- wrong chain ID fails closed without reading or broadcasting
- transport failure falls back to another verified endpoint
- broadcast response loss is not retried or echoed in error text
- RPC response must match the request id

### `test/core/chains/recipient_decoder_test.dart`（3项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/recipient_decoder_test.dart)

- EVM QR accepts only recipient and matching explicit network
- EVM QR rejects token-transfer targets and arbitrary embedded addresses
- existing Solana raw and payment QR extraction remains compatible

### `test/core/chains/solana_adapter_test.dart`（8项）

[源文件](../../apps/wallet_client_flutter/test/core/chains/solana_adapter_test.dart)

- validates base58 addresses and rejects EVM addresses
- aggregates token accounts using exact base units
- fee estimate retains exact Sender budget and destination
- native send reserves network fee and rent before building
- external custody does not invoke mnemonic reader
- signs the reviewed transfer and preserves Sender submission metadata
- does not sign a prepared payload attached to a changed request
- cross-network and negative requests are rejected before RPC

### `test/core/constants/app_constants_test.dart`（1项）

[源文件](../../apps/wallet_client_flutter/test/core/constants/app_constants_test.dart)

- default API configuration uses the production backend

### `test/core/network/api_client_test.dart`（5项）

[源文件](../../apps/wallet_client_flutter/test/core/network/api_client_test.dart)

- maps connection timeout errors to a friendly message
- uses endpoint fallback text for server errors
- retries read requests against a fallback backend
- maps connection timeout errors to a friendly message
- retries auth requests against a fallback backend

### `test/core/utils/amount_parser_test.dart`（7项）

[源文件](../../apps/wallet_client_flutter/test/core/utils/amount_parser_test.dart)

- accepts dot decimal input
- accepts comma decimal input from localized keyboards
- accepts grouped pasted values with dot decimals
- accepts grouped pasted values with comma decimals
- rejects invalid input
- converts decimal input to raw units without rounding up
- formats raw units with full token precision

### `test/features/auth/wallet_storage_regression_test.dart`（4项）

[源文件](../../apps/wallet_client_flutter/test/features/auth/wallet_storage_regression_test.dart)

- pre-existing encrypted mnemonic record decrypts without rewriting storage
- persisted account derivation remains attached to its ciphertext
- external custody cannot expose its encrypted PIN marker as mnemonic
- legacy standard and imported Solana addresses match independent SLIP-0010 vectors

### `test/features/multichain/chain_transfer_controller_test.dart`（7项）

[源文件](../../apps/wallet_client_flutter/test/features/multichain/chain_transfer_controller_test.dart)

- broadcast response loss retains exact transfer and known hash before submission
- locking after review prevents any signing
- locked session rejects Max before any network calculation
- locking during Max prevents returning a stale-wallet amount
- locking during signing prevents broadcast
- parallel confirmations serialize account signing and block duplicates
- fabricated unreviewed payload is rejected

### `test/features/multichain/multichain_store_test.dart`（4项）

[源文件](../../apps/wallet_client_flutter/test/features/multichain/multichain_store_test.dart)

- concurrent imports preserve both tokens and never rewrite old wallet data
- token lists are scoped to network and address
- Solana mint IDs remain case-sensitive
- base units round-trip at large amounts without floating-point loss

### `test/features/multichain/portfolio_value_test.dart`（3项）

[源文件](../../apps/wallet_client_flutter/test/features/multichain/portfolio_value_test.dart)

- mainnet valuation adds priced holdings and marks unknown tokens incomplete
- testnet is excluded even if an upstream supplies a fiat quote
- a backend outage is unavailable, not a known zero balance

### `test/features/multichain/widgets_test.dart`（18项）

[源文件](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart)

- receive history preserves Solana and routes other networks correctly
- child mode activity has network selection and no transfer actions
- legacy send history shows Solana in list and detail
- activity retains its network in list and detail while another network is selected
- unknown historical network keeps its identity instead of using selected network
- home defaults to both networks and filters shared asset rows
- Arc outage does not hide primary assets or prevent network selection
- unsupported Arc custody does not block original Solana receive
- shared send lists spendable Arc assets and opens the selected asset compose route
- zero-balance Arc send has the same empty asset selection as Solana
- missing selected Arc asset cannot silently compose another token
- receive switches QR/address with explicit network and no stale Solana address
- unsupported custody shows error instead of another networks address
- Arc compose rejects wrong addresses, nonpositive amounts and insufficient balance before estimation
- Arc Next reviews exact amount and fee, Cancel preserves input, Send explicitly submits
- Arc submission blocks duplicate Send and back while busy
- child mode cannot compose or confirm a transfer
- locked session cannot compose or confirm a transfer

### `test/features/notifications/chain_notification_test.dart`（3项）

[源文件](../../apps/wallet_client_flutter/test/features/notifications/chain_notification_test.dart)

- concurrent notification arrivals cannot overwrite each other
- network and root survive serialization; old Solana messages still parse
- retried FCM event deduplicates and preserves read state and deletion

### `test/features/settings/app_settings_repository_test.dart`（1项）

[源文件](../../apps/wallet_client_flutter/test/features/settings/app_settings_repository_test.dart)

- clearAll preserves the selected language

### `test/features/swap/solana_swap_scope_test.dart`（3项）

[源文件](../../apps/wallet_client_flutter/test/features/swap/solana_swap_scope_test.dart)

- Solana swap excludes EVM holdings, catalog and search results
- EVM pairs cannot reach Solana quote or build endpoints
- Arc swap notice is acknowledged once across page recreation

### `test/l10n/localization_coverage_test.dart`（7项）

[源文件](../../apps/wallet_client_flutter/test/l10n/localization_coverage_test.dart)

- target locales have every template message key
- supported locales include every language option
- language picker order is stable
- language picker options use native language names
- Android and iOS native localization resources exist
- presentation pages do not contain unlocalized visible literals
- used AppLocalizations keys exist in target locale ARB files

### `integration_test/android_qa/android_qa_wallet_flow_test.dart`（1项）

[源文件](../../apps/wallet_client_flutter/integration_test/android_qa/android_qa_wallet_flow_test.dart)

执行范围：独立、有资金发送/Swap副作用的QA配置；本轮未运行。

- QA full import wallet, history screens, send BYC, and swap

### `integration_test/arc/arc_backend_ui_test.dart`（1项）

[源文件](../../apps/wallet_client_flutter/integration_test/arc/arc_backend_ui_test.dart)

执行范围：真实Android存储/PIN + HTTP边界fixtures；此次脚本已同步空余额Send列表和禁用伪发送预期，但本轮未运行。不是线上主网联调。

- Android mainnet backend contract fixtures, PIN, receive, empty send selection and token sync

### `integration_test/arc/arc_emulator_smoke_test.dart`（1项）

[源文件](../../apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart)

执行范围：真实存储/PIN + 生产Arc主网5042接口；本轮2026-10-03执行105秒通过（1项testWidgets + tearDownAll，runner +2）。覆盖两链切换、收款地址/QR/复制/历史、新Send两链零余额空列表及metadata导入去重；无资金、无签名广播。构建21.1秒、安装7.5秒。此前2026-09-28通过记录保持为历史。

- Android real storage, PIN, Arc receive, empty send selection and token import

## 本轮覆盖边界

- 单元/组件测试采用公开、无资金fixture和mock，不证明生产数据库、原生安全硬件、真实广播或余额结算正确。
- Send的Arc无余额场景应像原Solana显示空列表，不为联调制造可发送资金。
- Max、QR解析和确认页面均不签名；只有确认页显式Send才进入已有签名/广播边界。
- 后台源代码和服务端用例位于 companion 仓库；本次客户端改动不修改其路由或数据库。服务端清单见 [后台测试计划](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_TEST_PLAN.md)。
- [tool/arc_read_smoke.dart](../../apps/wallet_client_flutter/tool/arc_read_smoke.dart) 是只读独立脚本，不属于flutter test；不签名/广播。
- 新注册名称代表存在自动化，实际是否通过以验证记录及运行范围为准；iOS、受控资金和真机仍按 [TEST_PLAN](TEST_PLAN.md) 执行。

## 历史快照与验证说明（保留原记录）

以下是原目录内容，日期、版本、计数和状态均保持原历史含义；当前名称/注册数应取上方2026-10-03快照。新增目录未将任何历史未测项目改为通过。

提取版本：`67da717`；2026-09-25。路径相对仓库根。下列名称来自实际 test/testWidgets 注册；不是额外新建的测试，也不是后台服务端测试。完整 test/ 套件本次运行72项通过；集成脚本单独运行，不计入这72项。逐行断言范围请阅读源文件。

执行方式和实际结果分别见 [DEVELOPMENT.md](DEVELOPMENT.md) / [VALIDATION.md](VALIDATION.md)。某些注册使用表驱动/组合fixture，不要把注册数、assert数、用例计划数与runner总数混为一谈。

## `test/core/chains/evm_adapter_test.dart`

[源文件](../../apps/wallet_client_flutter/test/core/chains/evm_adapter_test.dart)

- BIP44 derivation matches independent Ethereum vector
- EVM address rejects bad EIP55 mixed case, zero and missing prefix
- native/ERC20 USDC aliases deduplicate and preserve fee dust separately
- custom ERC20 metadata, exact balance and ABI transfer encoding
- invalid metadata decimals, malformed ABI and non-contract import fail
- fee estimation applies Arc floor and reserves combined USDC spend
- custom token needs both token balance and USDC fee balance
- typed EIP1559 envelope and hash match independent ethers vector
- network mismatch, wrong root mnemonic, stale nonce prevent signing
- altered reviewed amount or signed envelope cannot broadcast
- concurrent duplicate broadcast and ambiguous response never resubmit
- Arc receipt pending, success and reverted failure are distinguished
- other EVM networks await finalized block rather than Arc finality
- bounded history deduplicates incoming/outgoing logs and excludes USDC ERC20 alias
- tracked unknown submissions never leak to a different root wallet
- EIP191 and EIP712 match independent ethers signatures
- future signing intent decodes transfers and unlimited approvals, blocks blind review

## `test/core/chains/evm_rpc_test.dart`

[源文件](../../apps/wallet_client_flutter/test/core/chains/evm_rpc_test.dart)

- wrong chain ID fails closed without reading or broadcasting
- transport failure falls back to another verified endpoint
- broadcast response loss is not retried or echoed in error text
- RPC response must match the request id

## `test/core/chains/solana_adapter_test.dart`

[源文件](../../apps/wallet_client_flutter/test/core/chains/solana_adapter_test.dart)

- validates base58 addresses and rejects EVM addresses
- aggregates token accounts using exact base units
- fee estimate retains exact Sender budget and destination
- native send reserves network fee and rent before building
- external custody does not invoke mnemonic reader
- signs the reviewed transfer and preserves Sender submission metadata
- does not sign a prepared payload attached to a changed request
- cross-network and negative requests are rejected before RPC

## `test/core/constants/app_constants_test.dart`

[源文件](../../apps/wallet_client_flutter/test/core/constants/app_constants_test.dart)

- default API configuration uses the production backend

## `test/core/network/api_client_test.dart`

[源文件](../../apps/wallet_client_flutter/test/core/network/api_client_test.dart)

- maps connection timeout errors to a friendly message
- uses endpoint fallback text for server errors
- retries read requests against a fallback backend
- maps connection timeout errors to a friendly message
- retries auth requests against a fallback backend

## `test/core/utils/amount_parser_test.dart`

[源文件](../../apps/wallet_client_flutter/test/core/utils/amount_parser_test.dart)

- accepts dot decimal input
- accepts comma decimal input from localized keyboards
- accepts grouped pasted values with dot decimals
- accepts grouped pasted values with comma decimals
- rejects invalid input
- converts decimal input to raw units without rounding up
- formats raw units with full token precision

## `test/features/auth/wallet_storage_regression_test.dart`

[源文件](../../apps/wallet_client_flutter/test/features/auth/wallet_storage_regression_test.dart)

- pre-existing encrypted mnemonic record decrypts without rewriting storage
- persisted account derivation remains attached to its ciphertext
- external custody cannot expose its encrypted PIN marker as mnemonic
- legacy standard and imported Solana addresses match independent SLIP-0010 vectors

## `test/features/multichain/chain_transfer_controller_test.dart`

[源文件](../../apps/wallet_client_flutter/test/features/multichain/chain_transfer_controller_test.dart)

- broadcast response loss retains exact transfer and known hash before submission
- locking after review prevents any signing
- locking during signing prevents broadcast
- parallel confirmations serialize account signing and block duplicates
- fabricated unreviewed payload is rejected

## `test/features/multichain/multichain_store_test.dart`

[源文件](../../apps/wallet_client_flutter/test/features/multichain/multichain_store_test.dart)

- concurrent imports preserve both tokens and never rewrite old wallet data
- token lists are scoped to network and address
- Solana mint IDs remain case-sensitive
- base units round-trip at large amounts without floating-point loss

## `test/features/multichain/widgets_test.dart`

[源文件](../../apps/wallet_client_flutter/test/features/multichain/widgets_test.dart)

- receive history preserves Solana and routes other networks correctly
- child mode activity has network selection and no transfer actions
- home defaults to both networks and filters shared asset rows
- shared send selects Arc inline and clears its form on network switch
- receive switches QR/address with explicit network and no stale Solana address
- unsupported custody shows error instead of another networks address
- send reviews exact USDC amount and fee before explicit signing
- child mode cannot compose or confirm a transfer
- locked session cannot compose or confirm a transfer

## `test/features/settings/app_settings_repository_test.dart`

[源文件](../../apps/wallet_client_flutter/test/features/settings/app_settings_repository_test.dart)

- clearAll preserves the selected language

## `test/l10n/localization_coverage_test.dart`

[源文件](../../apps/wallet_client_flutter/test/l10n/localization_coverage_test.dart)

- target locales have every template message key
- supported locales include every language option
- language picker order is stable
- language picker options use native language names
- Android and iOS native localization resources exist
- presentation pages do not contain unlocalized visible literals
- used AppLocalizations keys exist in target locale ARB files

## `integration_test/android_qa/android_qa_wallet_flow_test.dart`

[源文件](../../apps/wallet_client_flutter/integration_test/android_qa/android_qa_wallet_flow_test.dart)

执行状态：Arc为历史未注资模拟器通过；android_qa为有转账/Swap副作用的独立配置测试，本轮未运行。

- QA full import wallet, history screens, send BYC, and swap

## `integration_test/arc/arc_emulator_smoke_test.dart`

[源文件](../../apps/wallet_client_flutter/integration_test/arc/arc_emulator_smoke_test.dart)

执行状态：Arc为历史未注资模拟器通过；android_qa为有转账/Swap副作用的独立配置测试，本轮未运行。

- Android real storage, PIN, Arc receive, forms and token import

## 只读在线检查

[tool/arc_read_smoke.dart](../../apps/wallet_client_flutter/tool/arc_read_smoke.dart) 是独立脚本，不属于 flutter test；链ID、USDC精度、gasPrice、系统日志和可选公开地址历史，禁止签名/广播。

## 覆盖边界

- `api_client_test.dart` 使用mock；不证明真实后台鉴权、数据库或权限正确。
- 加密fixture/公开派生向量不证明所有已发布生产存储版本都兼容。
- 组件测试不验证原生安全硬件、真实链上余额结算或商店签名包。
- 未注资Arc集成不会执行真实发送；有资金验收看TEST_PLAN的E2E组。
- 初版没有后台服务端或 iOS 成功证据；2026-09-26 增补后台 22 项测试与 iOS 无签名 debug 构建，见最新 VALIDATION。自动截图回归、全语言翻译和完整设备测试仍未覆盖。

维护方法：添加/重命名/删除测试时同步本目录，重新运行flutter test记录runner计数；不要自动将新列出的测试标为通过。

## 2026-09-25 Android 回归增补

现有Arc集成测试增加：Send/Receive/Swap的横向顺序、full/lite功能开关、Arc-only不展示Swap、两链本地AssetImage角标。菜单点击改为命中实际菜单项，避免文本子节点的hit-test警告。测试名称不变，不改变72项本地单元/组件测试计数；full与lite模式分别执行，结果见VALIDATION最新记录。


## 2026-09-26 新增自动化

- `test/core/chains/chain_backend_client_test.dart`：默认主网/费用参数；固定所有权证明；API 主机鉴权；网络不匹配；广播不重试；会话切换；资产精度；日志/交易摘要去重。
- `test/features/multichain/portfolio_value_test.dart`：主网总额与未知报价；测试网排除；后台失败不能代表零余额。
- `test/features/notifications/chain_notification_test.dart`：网络/根账户序列化兼容；重试事件保留已读/删除；并发通知不互相覆盖。
- `integration_test/arc/arc_backend_ui_test.dart`：真实 Android 存储/PIN + HTTP 边界 fixtures，验证主网共用 UI 与新接口合同；**不是线上主网联调**。
- 原 `arc_emulator_smoke_test.dart` 保留，直接公共测试网运行须显式传 `ARC_USE_TESTNET` + `ARC_DIRECT_TESTNET_RPC` 两个开关。
- 后台 `apps/wallet_api/test/arc.test.ts`、`arc-database.test.ts`：服务/路由/索引/通知与 PGlite 权限/事务测试，逐项清单见 [后台矩阵](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_TEST_PLAN.md)。

本轮实际通过数字、平台结果及日期以 [VALIDATION](VALIDATION.md) 最新记录为准。

## 2026-09-27 存量用户回归增补

- `wallet_storage_regression_test.dart` 原旧记录用例增强：解密、派生 Arc、重开、地址稳定与密文字节不变，Solana 地址保持。
- `widgets_test.dart` 新增 `Arc outage does not hide primary assets or prevent network selection` 和 `unsupported Arc custody does not block original Solana receive`。
- 后台新增 `Arc failure and chain-header policy stay inside the Arc plugin`，仅验证 sibling 合同路由隔离，不代替真实 Solana 后台回归。
- 全量客户端 88、后台 23 项通过；参考最新 VALIDATION。

2026-09-28：现有 arc_emulator_smoke_test.dart 同时支持显式主网生产 QA；新增主网保护参数、动态网络断言，仍为同一testWidgets用例。真实生产模式51秒通过，范围见VALIDATION；单元/组件总数未改变。

## 2026-09-28 `test/features/swap/solana_swap_scope_test.dart`

新增 3 项，实际执行结果见 [VALIDATION](VALIDATION.md)。

- Solana swap excludes EVM holdings, catalog and search results
- EVM pairs cannot reach Solana quote or build endpoints
- Arc swap notice is acknowledged once across page recreation

## 2026-09-29 历史网络身份回归

`test/features/multichain/widgets_test.dart` 新增 3 项（现共 14 项）：

- legacy send history shows Solana in list and detail
- activity retains its network in list and detail while another network is selected
- unknown historical network keeps its identity instead of using selected network

历史截图先等待本地图标解码。实际结果及证据见 [NETWORK_UI_AUDIT](NETWORK_UI_AUDIT.md)。
