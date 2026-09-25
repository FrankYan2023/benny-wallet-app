# Arc / Multichain 文档入口

更新时间：2026-09-25。目标分支：`arc`。原开发分支：`codex/milestone-2-arc`。起点：`08cbed3`（Android v0.0.50）。发布准备时的最新功能提交：`67da717`。

## 阅读顺序

1. [AI_HANDOFF.md](AI_HANDOFF.md)：新 AI / 新工程师首先阅读。
2. [CHANGELOG.md](CHANGELOG.md)：4 次实现提交、决策变更、逐文件清单。
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
| Android liteStore 调试包 | 已构建/安装，不等于签名发布包 |
| 最新功能代码完整单元/组件测试 | 72 项通过（2026-09-25 重新执行） |
| Arc RPC 只读、未注资模拟器路径 | 历史执行通过，见验证记录版本范围 |
| 有资金的完整发送/接收/回执 | 待执行，当前没有链上转账验收证据 |
| iOS 编译/设备测试 | 构建环境阻塞，未通过 |
| 生物识别硬件、旧生产版本恢复、后台端到端 | 待执行；不宣称安全迁移或完整回归 |
| Arc Swap/Bridge/完整 WalletConnect | 明确不在第一版范围 |

`TEST_PLAN.md` 是计划，`VALIDATION.md` 是事实记录，Git commit 是实现历史。三者不能互相替代。

## 界面证据

[最新首页](evidence/home-network-badges.png)（`67da717`）：All / Solana / Arc；Send → Receive → Swap；代币角标显示链。
[共用 Send](evidence/shared-send.png)、[共用 Receive](evidence/shared-receive.png) 来自 2026-09-25 的统一界面检查，早于角标微调。截图为专用无资金 QA 钱包，只证明界面状态，不证明真实转账成功。

## 后续维护

每次变更保留旧日期/提交记录，添加新的验证记录；不要覆盖成“全部通过”。在任务结束时记录未完成事项、原因、所需环境和建议下一步。代码与文档冲突时先查实际 HEAD，再修正文档。所有主网参数必须在实际启用前重新核对。
