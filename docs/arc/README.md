# Arc / Multichain 文档入口

更新时间：2026-09-26。两个仓库均使用 `arc` 分支。先读 [MAINNET_PARITY](MAINNET_PARITY.md) 与 [后台实施文档](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_MULTICHAIN.md)；客户端默认主网/后台模式，生产上线尚待部署与链上验收。下表中标注 2026-09-25 的记录保留为历史证据。

## 阅读顺序

1. [AI_HANDOFF.md](AI_HANDOFF.md)：新 AI / 新工程师首先阅读。
2. [CHANGELOG.md](CHANGELOG.md)：历次实现提交、前后端决策变更、逐文件清单。
3. [MILESTONE_2_ARC.md](../../MILESTONE_2_ARC.md)：架构、存储、派生和链配置的原始技术记录。
4. [DEVELOPMENT.md](DEVELOPMENT.md)：本地运行和复测命令。
5. [TEST_PLAN.md](TEST_PLAN.md)：全部需要执行的测试；[AUTOMATED_TESTS.md](AUTOMATED_TESTS.md) 是现有自动化的逐条目录。
6. [BACKEND_CONTRACTS.md](BACKEND_CONTRACTS.md)：后台/客户端接口边界与联调需求。
7. [VALIDATION.md](VALIDATION.md)：真实执行结果与发布门槛。

## 当前结论

| 范围 | 状态 |
| --- | --- |
| Solana/EVM 抽象、兼容根钱包派生、Arc 基本服务 | 已实现；有本地自动化覆盖 |
| 两链首页、共用 Send/Receive、链标识与操作顺序 | 已实现；Android 模拟器已检查 |
| Android调试包 | 当前 full/liteStore 构建与模拟器集成通过；liteSeeker 仅有 09-25 历史证据，硬件/签名发布待验收 |
| 单元/组件与后台测试 | Flutter 88 项、后台 23 项通过；环境/日期见 VALIDATION |
| Android 未注资模拟器路径 | 主网 API fixture full/lite 通过；真实公共测试网 full 回归通过，未广播 |
| 有资金的完整发送/接收/回执 | 待执行，当前没有链上转账验收证据 |
| iOS 编译/设备测试 | 09-26 无签名 debug 构建通过；模拟器/真机/签名发布待验收 |
| 生物识别硬件、旧生产版本恢复、后台端到端 | 待执行；不宣称安全迁移或完整回归 |
| Arc Swap/Bridge/完整 WalletConnect | 明确不在第一版范围 |

`TEST_PLAN.md` 是计划，`VALIDATION.md` 是事实记录，Git commit 是实现历史。三者不能互相替代。

## 界面证据

[最新首页](evidence/home-network-badges.png)（`67da717`）：All / Solana / Arc；Send → Receive → Swap；代币角标显示链。
[共用 Send](evidence/shared-send.png)、[共用 Receive](evidence/shared-receive.png) 来自 2026-09-25 的统一界面检查，早于角标微调。截图为专用无资金 QA 钱包，只证明界面状态，不证明真实转账成功。

## 后续维护

每次变更保留旧日期/提交记录，添加新的验证记录；不要覆盖成“全部通过”。在任务结束时记录未完成事项、原因、所需环境和建议下一步。代码与文档冲突时先查实际 HEAD，再修正文档。所有主网参数必须在实际启用前重新核对。

- [存量用户与 Android 真机联调](EXISTING_USER_ANDROID.md)：兼容审查、生产接口前提、升级包签名与测试顺序。
