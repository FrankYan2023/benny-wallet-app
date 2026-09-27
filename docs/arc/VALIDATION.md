# 验证记录与待验收事项

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
