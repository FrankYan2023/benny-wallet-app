# 存量用户兼容性与 Android 真机联调

检查日期：2026-09-27。运行代码：客户端 `460cd44`、后台 `283f8a5`；本次增补测试与文档，不修改运行逻辑。此检查不等于全部历史生产版本或真实用户数据已验收。

## 已检查的兼容边界

- 对照客户端发布基线 `08cbed3`：`wallet_repository.dart`、`wallet_controller.dart`、`core/crypto`、`core/storage`、`core/security` 与整个 Android 目录无差异。加密记录名、PIN 加解密、原生 Keystore、包名/签名配置没有因 Arc 修改。
- Solana 原派生路径和已有 `sendSol`/`sendSplToken` 保留。原费用方法包装新增整数单位方法，Sender tip、priority fee、safety buffer 算法不变；新增适配器辅助方法不替换旧发送入口。解锁页仅把 mounted 检查移到 UI 状态更新之前。
- 兼容本地助记词在解锁后按独立 EVM 路径派生地址；先核对原 Solana 地址。Arc 不重写旧根记录，也不创建新恢复词。外部 MWA/Seed Vault 没有本地助记词时，只拒绝 Arc 能力，保留 Solana。
- Arc 资产/活动是独立异步 provider，后台不可用不进入 Solana 刷新等待列表。All 显示 Solana 数据与 Arc 错误/总额不完整提示；选择 Solana 后可继续使用原页面。
- 后台新增 Arc 为封装插件，链头、限流、错误处理仅作用于 Arc 路由。旧 Solana 请求不需要增加 `X-Chain-Id`。新增 SQL 只创建 `wallet_chain_*` 表/函数，不修改原 Solana 表或用户钱包记录。
- 仍共享 API 进程、数据库和通知服务，不能保证没有资源竞争。生产上线前需要容量、配置、原 Solana API 的 staging 回归；Arc 开关关闭可回滚功能，保留数据。

## 本次自动化证据

- 增强旧加密记录测试：解密 → Arc 派生 → 重新打开旧记录 → Arc 地址稳定、Solana 地址一致、旧密文逐字节不变。
- 新增页面测试：Arc 请求失败时主资产仍可见且能切回 Solana；不支持 Arc 的账户在两链切换后仍显示原 Solana 地址/二维码。
- 新增后台插件隔离测试：Arc RPC 失败时 sibling Solana 合同测试路由仍接收旧 Bearer 请求、不要求 Arc 链头；未认证请求仍被拒绝。这是插件隔离测试，不是线上 Solana RPC 收发证明。
- 全量客户端 **88 项通过**；后台 **23 项通过**。静态检查结果及历史平台构建见 [VALIDATION](VALIDATION.md)。

## 部署接口后可以开始 Android 真机调试吗？

可以。界面、解锁和地址生成可提前在专用手机检查；完整余额/历史/发送联调需以下条件同时满足：

1. 生产或隔离 staging 环境先应用新增 SQL，部署后台；配置 `ARC_ENABLED=true`、`ARC_NETWORK=mainnet`、有效 `ARC_RPC_URLS`。历史/到账索引另启用 `ARC_INDEXER_ENABLED=true`；推送需要真实 FCM 配置。
2. 从部署环境验证 RPC、账户绑定、余额、费用、收据和日志，不能仅以服务器启动或 health 返回 200 代替验证。之前开发机的主网 403 仍未解决；生产节点可访问性必须独立确认。
3. 安装普通 `main.dart` 构建，`API_BASE_URL` 指向部署的 HTTPS 后台。当前默认 `https://api.gobennyapp.com`。保持默认主网，不启用 `ARC_USE_TESTNET`、`ARC_DIRECT_TESTNET_RPC` 或 `BENNY_EMULATOR_QA`，不要将测试 harness 安装到个人钱包设备。
4. 先在专用测试手机启用 USB 调试并连接，使用新建的私有受控测试钱包；先测无资金流程，再按测试计划完成小额 USDC/ERC-20 收发与费用/回执核对。公开测试向量和公开 QA PIN 钱包不能注资。
5. 存量升级另做受控测试：旧版创建测试钱包 → 新版同包名、同签名覆盖安装 → 核对 PIN、生物识别、Solana 地址/资产/收发/Swap → 启用 Arc → 重启、锁定和切换账户后再核对。商店版本还要匹配商店签名升级通道和递增 versionCode。

Android 当前包名：full `com.benny.wallet`，liteStore `com.benny.wallet.lite`，liteSeeker 默认 `com.benny.wallet.lite.seeker`。普通 debug 签名通常不能覆盖已安装的生产签名包。遇到签名冲突不得卸载旧钱包或清数据来绕过；改用专用测试设备/用户空间，或者使用正确签名的受控升级包。未检查或改变任何本机生产签名凭据。

建议先测：旧钱包解锁/地址保持 → Solana 收发与 Swap → Arc 地址/余额/收款 → Arc 估费/确认/广播/回执 → 后台断开时 Solana 可用性 → 多设备历史与通知 → 真机生物识别。完整用例见 [TEST_PLAN](TEST_PLAN.md) 及 [后台矩阵](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_TEST_PLAN.md)。

本轮没有执行生产部署、远程数据库迁移、个人手机安装或真实资金转账。
