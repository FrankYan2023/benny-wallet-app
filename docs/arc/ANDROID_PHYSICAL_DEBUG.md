# Android 真机联调

## 2026-10-03 启动记录

客户端运行代码 `a2bc494`，分支 `arc`；Seeker / Android 16（API 36）/ ARM64。普通 `lib/main.dart`、full + STORE_MODE=full，生产API `https://api.gobennyapp.com`，Arc默认主网5042，经 `/v1/arc-rpc`。

已有 `com.benny.wallet.lite`（0.0.51/51）保留，本次独立新装 **Benny Wallet Full** / `com.benny.wallet`（0.0.50/50，debug）。两个包没有sharedUserId，钱包/PIN/应用数据独立；没有卸载、清数据、覆盖Lite或读取其助记词。安装后Lite版本和更新时间不变，不代表钱包内部记录或旧版原地升级已验收。

## 启动命令

先用 `flutter devices` 获取当前设备ID：

```sh
cd apps/wallet_client_flutter
flutter run --no-pub -d <ANDROID_DEVICE_ID> --flavor full -t lib/main.dart \
  --dart-define=STORE_MODE=full \
  --dart-define=API_BASE_URL=https://api.gobennyapp.com \
  --dart-define=FEATURE_APP_UPDATES_ENABLED=false
```

本次保留默认 `FEATURE_SEEKER_VAULT_ENABLED=true`，但没有执行Vault授权/硬件签名验收。Arc只支持有本地根助记词的软件钱包；SeedVault/MWA没有本地助记词时仍保留Solana，不转换/导出其私钥。测试钱包与PIN由持有人自行创建，不导入有资金钱包，不使用公开模拟器QA钱包。

不传 `ARC_USE_TESTNET`、`ARC_DIRECT_TESTNET_RPC`、`BENNY_EMULATOR_QA`、`ARC_PRODUCTION_QA`；不安装集成测试入口。

## 实际结果

| 检查 | 2026-10-03 结果 |
| --- | --- |
| 识别、full debug构建、独立安装 | 通过；构建16.6秒、安装5.4秒 |
| 普通启动、欢迎页、调试连接 | 通过；文件同步196ms，新建/导入入口可见 |
| AndroidRuntime/Flutter错误级崩溃检查 | 检查时无输出；不能推断所有流程无错误 |
| 原Lite保留 | 包版本/安装更新时间不变；未检查其私有存储 |
| 生产只读接口（电脑执行） | 认证、主网配置/错误链拒绝/health、Supabase未绑定账户读取、chainId、余额、USDC decimals、估费、gasPrice、feeHistory、receipt、区块、logs、原Solana余额通过 |
| 历史索引健康 | 未通过；启用但16:42/16:43Z观察到重试错误，最后成功16:38:40Z；接口通过不能代替索引验收 |
| 手机钱包初始化及认证后双链流程 | 待持有人创建私有无资金软件测试钱包、设置PIN并进入首页 |
| 生物识别、扫码、资金、推送、旧版原地升级 | 未执行 |

索引错误为 `Arc index pass failed; cursors retained for retry.`，带indexer健康断言的探测失败；不带该断言的只读RPC探测通过。不能隐藏这一差异。

16:46Z只读诊断仍有错误，但部分live/backfill游标在推进。公开原生Transfer过滤在genesis、近期和旧回填100块范围经生产RPC均正常；聚合游标观察指向部分账户回填未推进，不能确定具体事件或处理步骤。worker当前只记录固定脱敏错误，需补安全的阶段/错误类别诊断后复查；没有为诊断修改数据库、配置或部署。

Firebase runtime options未配置，不能验收FCM送达；另有310项中文缺失、既有Gradle/AGP/Kotlin支持提示与Seeker vendor gralloc格式警告，欢迎页实际可见。没有应用源码、依赖、后台或数据库改动；Flutter自动追加的Gradle兼容属性已恢复，重建可能再次生成。

## 真机后续验收

| 顺序 | 内容 | 状态 |
| --- | --- | --- |
| 1 | 持有人创建无资金软件钱包/PIN、进入首页，不共享助记词/PIN | 待完成 |
| 2 | All默认两链；筛选/图标/余额/下拉同宽与无覆盖 | 待执行 |
| 3 | Receive切链、地址/QR/网络提示/复制 | 待执行 |
| 4 | Send统一币种列表/空态；正余额时填写→确认；无效地址/金额/不足费用 | 待执行；空钱包不能覆盖正余额路径 |
| 5 | Solana-only Swap及首次提示；历史所属链、刷新与索引异常恢复 | 待执行 |
| 6 | 前后台恢复、PIN/生物识别、摄像头QR与拒绝权限 | 待执行；凭据和敏感授权由持有人完成 |
| 7 | 独立受控私有钱包小额收发、费用/receipt/实际余额与历史核对 | 未执行；需明确金额/接收地址，资金操作由持有人完成 |
| 8 | 正确发布签名/版本号的受控旧版升级、地址/PIN/密钥不变 | 未执行；full/Lite共存不算升级测试 |

完整用例见 [TEST_PLAN](TEST_PLAN.md)、[EXISTING_USER_ANDROID](EXISTING_USER_ANDROID.md)。后续实际结果追加 [VALIDATION](VALIDATION.md)，不将启动成功写成真机钱包闭环通过。
