# 验证记录与待验收事项

## 最新功能代码：67da717（2026-09-25）

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

## 当前必须补齐

| 项目 | 状态/原因 | 下一步与测试ID |
| --- | --- | --- |
| 独立私有测试钱包实际USDC/ERC20收发、费用/回执 | 未注资，无链上闭环证据 | E2E-01…08、CH-16/17；保留hash和余额核对 |
| iOS编译、模拟器、真机 | 开发环境阻塞 | PLAT-03/04；初始化Xcode/CocoaPods再运行 |
| Android/iOS生物识别与安全存储升级 | 模拟器不能证明硬件安全；历史实现有绑定限制 | SEC-02…07，在受控设备/旧版本测试 |
| 服务端完整回归 | 没有该仓库源代码/部署测试上下文 | BE-01…18，记录server commit/staging环境 |
| 发布flavor/签名/release配置 | 仅liteStore debug UI构建 | PLAT-02/07；逐SKU验证STORE_MODE和flags |
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
