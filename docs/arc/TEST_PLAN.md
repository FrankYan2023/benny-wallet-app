# Milestone 2 完整测试计划

截至 2026-09-25。覆盖当前需求及发布必须补齐的回归项；不是所有可能输入的穷举。**本表描述应执行的验收，不表示已经通过。** 每次执行须在 [VALIDATION.md](VALIDATION.md) 记录 ID、代码提交、环境和证据。现有逐条测试见 [AUTOMATED_TESTS.md](AUTOMATED_TESTS.md)。

## 优先级、方法和数据

- **P0**：资金、密钥、地址、权限、签名、核心收发、发布平台构建。未通过不可宣称 MVP 已验收。
- **P1**：错误恢复、显示准确性、原功能回归、后台契约。发布前处理，或记录经产品确认的例外。
- **P2**：扩展体验、长时间运行和未来接口；不把明确的未来功能加入第一版范围。
- **A**：已有相关自动化，但仅覆盖测试目录列出的具体断言，不代表整行端到端通过。
- **M**：需要模拟器/人工或注入故障；**D**：需要物理设备；**S**：后台 staging；**F**：独立私有测试钱包与测试网资金。
- 默认数据：空钱包；USDC 单一余额；自定义 0/6/18 decimals 合约；无效/混合大小写地址；账户 A/B；同根不同 Solana index；不同根；MWA/Seed Vault；儿童模式；RPC timeout/429/500/错误链；后台 expired/foreign token。
- 私有 F 钱包与公开固定助记词测试向量、PIN `258025` 的模拟器钱包隔离。只使用可丢弃测试资产；不要导出/提交助记词。失败重试前查链上哈希，避免重复付款。

## 前端：钱包、首页与路由

| ID | 优先级/方法 | 操作与输入 | 预期结果 |
| --- | --- | --- | --- |
| FE-01 | P0 A/M | 兼容钱包解锁后冷启动首页 | 默认 All；同页显示 Solana 和 Arc；无独立 Arc 收发模块 |
| FE-02 | P1 A/M | All → Arc → Solana → All；每次刷新 | 网络行/余额过滤一致；单链失败不隐藏另一链 |
| FE-03 | P1 A/M | 检查按钮并分别点击；Arc-only、儿童模式、STORE_MODE=lite | 顺序 Send→Receive→Swap；导航正确；Arc-only/开关关闭不显示 Swap，儿童仅接收 |
| FE-04 | P1 A/M | SOL、Solana USDC、Arc USDC、Arc 自定义币；断网重启 | 每个币头像右下角显示所属链；离线标识仍在，不按币种符号推测链 |
| FE-05 | P0 A/M | 两链均有 USDC；Arc 测试网余额变化 | 不重复显示 native/ERC-20 USDC；测试网不进入真实美元合计 |
| FE-06 | P1 M | 空列表、零余额、loading、请求失败、下拉刷新 | 状态明确，0 不伪装为请求成功；能重试，无永久转圈 |
| FE-07 | P1 M | 同根不同 Solana index、不同根钱包切换 | 地址/余额/活动/导入币按正确网络账户切换，无前一钱包残影 |
| FE-08 | P1 A/M | 各币详情进入 Send/Receive，含无 Swap 模式 | 保留币与网络；Solana 详情不会继承之前的 Arc 选择 |
| FE-09 | P0 A/M | 锁定/儿童模式打开 Send、导入、旧 network/send 深链 | 守卫生效；旧链接跳转共用 Send；不可绕过签名限制 |
| FE-10 | P1 M | 错误 network/asset 参数、已删除钱包、返回栈重复进入 | 不崩溃、不意外选错网络；无效参数需明确拒绝/安全回退 |
| FE-11 | P1 M/D | 解锁处理中快速返回、旋转、切后台再回来 | 无 disposed widget 更新/黑屏；锁屏和返回路径正确 |

## 前端：接收、发送、导入与活动

| ID | 优先级/方法 | 操作与输入 | 预期结果 |
| --- | --- | --- | --- |
| FE-12 | P0 A/M | Receive 切 Solana/Arc；扫描二维码并复制 | 全地址/二维码/剪贴板同属选中网络，无截断内容进入剪贴板 |
| FE-13 | P1 A/M | 从接收页进入历史；两条链分别返回 | Solana 保留既有历史；Arc 打开对应活动，返回仍可选择网络 |
| FE-14 | P0 A/M | 无本地助记词的外部托管选择 Arc | 明确不支持，不显示伪造/错误地址，不触发派生 |
| FE-15 | P0 A/M | Send 切网络、选币、输入地址和数量后再切网络 | 在共用页面完成；切换清旧表单；确认期间网络不可切换 |
| FE-16 | P0 A/M | 空/零地址、Solana 地址用于 EVM、缺0x、错误 checksum、空白输入 | 阻止无效地址；正当 EVM 地址正确通过；错误提示可理解 |
| FE-17 | P0 A/M | 空/负/零数量、超精度、科学计数、逗号/点输入、极大值 | 不舍入增加支付额，不产生浮点误差；不支持格式明确拒绝 |
| FE-18 | P0 A/M/F | 余额不足、刚好等于余额、足够币但无 USDC gas | 明确显示缺少资产或手续费；不允许不够 gas 的全额发送 |
| FE-19 | P0 A/M | 准备交易→核对→取消；修改金额后再次准备 | 确认完整 network/token/contract/recipient/amount/max fee；取消不签名，修改需重新确认 |
| FE-20 | P0 A/M | 连点确认、准备过期、签名前/中途锁定、切账户 | 单次提交；过期/账户变化/锁定阻止签名或广播 |
| FE-21 | P0 A/M/F | 广播断网或响应丢失 | 保留本地计算 hash 和未确定状态；无自动重发或假成功/假失败 |
| FE-22 | P1 A/M | 导入 USDC 预部署地址、大小写重复、自定义 BENNY | USDC 只一行；合约去重；显示真实 metadata，不靠 symbol 确认真伪 |
| FE-23 | P0 A/M | EOA、无代码地址、错误 ABI、超长/控制/双向字符、坏 decimals | 安全拒绝导入；错误可恢复；列表/布局不受恶意 metadata 影响 |
| FE-24 | P1 M | 导入请求进行中返回、切网、断网后重试 | 不污染另一个网络/账户，不重复保存 |
| FE-25 | P0 A/M/F | pending→成功/回退；找不到 receipt；RPC失联 | Arc 成功/失败以回执为据；未知不等于失败；显示费用、hash、网络 |
| FE-26 | P1 A/M | 刷新活动、前后台、重复日志、同交易多 Transfer | 无重复项/并发轮询失控；显示正确每笔资产数量 |
| FE-27 | P1 M | 点击 explorer、地址复制、哈希复制 | 跳到当前网络配置的正确目标；回到应用状态正常 |
| FE-28 | P1 M | 活动为空、超过1000块、超过100条本地提交 | 空态与历史边界明确；不宣称完整历史 |
| FE-29 | P1 M/D | 小屏、横屏、键盘Next/Back、130%和200%字号、TalkBack/VoiceOver | 输入/按钮可达、重点字段可阅读，无溢出；链标签与费用可被读屏理解 |
| FE-30 | P1 A/M | 中文/英文和其他现有语言；暗色/亮色 | 文案/数字不混乱；其他语言fallback可接受；记录未翻译项，不能把ARB存在等同翻译完整 |
| FE-31 | P1 M | Solana资产、详情、Swap/xStocks/DeFi、空投、通知、设置入口回归 | 原功能与配置保持；无 Arc UI改动引起的导航/筛选退化 |

## 链服务与签名（客户端“后台逻辑”，不是服务端）

| ID | 优先级/方法 | 操作与输入 | 预期结果 |
| --- | --- | --- | --- |
| CH-01 | P0 A | 独立 BIP39/BIP44 地址向量 | secp256k1 / m/44'/60'/0'/0/0 与独立实现一致 |
| CH-02 | P0 A | Legacy/standard/custom Solana 派生向量 | 原地址不变；正确保留 accountIndex/changeIndex |
| CH-03 | P0 A/M | mnemonic 与 persisted Solana owner 不匹配 | EVM账户创建失败；不会把另一根资金暴露到当前钱包 |
| CH-04 | P0 A | native18/USDC6 极小值、精度边界、余额兑换 | 精确 BigInt；单一经济余额；不丢失 fee 精度 |
| CH-05 | P0 A | name/symbol/decimals/balanceOf/transfer ABI | 标准metadata/余额/编码正确，恶意返回安全拒绝 |
| CH-06 | P0 A | EIP1559/chainId/nonce/to/value/data/gas 签名向量 | 类型2编码、链防重放；篡改已确认字段或签名包不能广播 |
| CH-07 | P0 A | feeHistory缺失/异常、gasPrice floor、estimateGas错误 | 正确floor/20%gas margin与最大成本；不能用0费用假估算 |
| CH-08 | P0 A | nonce过期、并行付款、丢失响应后重试 | 防冲突与重复提交；失败原因可追查，无盲目重发 |
| CH-09 | P0 A | owner/session/child变化、确认超时2分钟、重复使用review | 签名前和广播前限制生效；确认不能重放 |
| CH-10 | P0 A | Solana SOL/SPL/Token2022、rent/priority/tip reserves | adapter保留旧逻辑与精确基础单位，不能花掉保留费用 |
| CH-11 | P0 A | MWA/SeedVault调用Solana adapter | 不读本地助记词；外部签名路径保留 |
| CH-12 | P0 A | EIP191与EIP712 V4独立签名/错误domain chain | 与向量一致；拒绝错误chain域；没有暴露通用盲签UI |
| CH-13 | P1 A | transfer/approve/unlimited/unknown calldata 解码 | 人类可读意图准确；未知操作需额外审查，不当成普通转账 |
| CH-14 | P0 A/M | RPC返回错误chainId（含fallback）、HTTP非TLS配置 | fail closed；不继续读/签/广播到错误链 |
| CH-15 | P1 A/M | RPC timeout/429/5xx/坏JSON/id不匹配/error对象 | 读故障按规则切换且校验网络；清晰脱敏错误；广播不自动重试 |
| CH-16 | P0 A/F | receipt成功/失败/null、实际gasUsed/effectiveGasPrice | 准确状态/实际费用；Arc包含即确定，非Arc按其finality策略 |
| CH-17 | P1 A/M/F | 100块分段扫描1000块、incoming/outgoing、native/USDC双事件 | 连续无漏段；按hash/log去重；使用正确18/6精度；fee不从日志猜 |
| CH-18 | P0 A | 并发导币/记录活动、同地址不同链、Solana mint大小写 | 不丢写；按账户/链隔离，Solana大小写不被EVM归一化 |
| CH-19 | P1 M | metadata损坏、版本未知、钱包删除、应用重启 | 可恢复错误；公开旧记录不误归属新钱包；文档准确说明保留策略 |
| CH-20 | P1 M | RPC配置更换、BENNY地址错误、fallback关闭 | 不改UI即可配置；错误明确，不能悄悄使用错误合约 |

## 真实测试网闭环（待执行）

| ID | 优先级/方法 | 操作与输入 | 预期/证据 |
| --- | --- | --- | --- |
| E2E-01 | P0 F/D | 两个私有测试钱包A/B；各保存公开Sol/EVM地址与测试前余额 | 地址与独立派生/设备展示一致；不记录秘密 |
| E2E-02 | P0 F/D | 向A接收少量Arc测试USDC | 余额单行更新；日志/回执/fee精度正确；记录入账hash |
| E2E-03 | P0 F/D | A经UI向B发送USDC，再由B回收少量 | review→显式签名→广播→final；双端余额变化吻合金额与实际费 |
| E2E-04 | P0 F/D | 测试ERC20（BENNY经发行方确认后可替代）导入、接收、发送 | 合约/decimals正确；token减少数量，USDC只扣gas，无重复资产 |
| E2E-05 | P0 F | 故意触发回退、nonce冲突、余额不足、提交后断网 | 不错误标成功；回退只扣应付gas；响应丢失可恢复查询 |
| E2E-06 | P0 F/D | 支持环境下回归既有Solana发送/接收（受控小额） | 原账户/费用/Sender/确认正常；不借Arc任务测试未授权主网支付 |
| E2E-07 | P0 F/D | Android/iOS同私有根、重启/锁定/解锁后重复收发 | 两平台地址一致、原Solana地址不变；无跨钱包状态泄漏 |
| E2E-08 | P1 F | adapter native/value路径的独立测试（非普通USDC UI路径） | native amount18精度、链id、回执/系统日志正确 |

## 后台（独立仓库/环境，全部需要服务端执行记录）

准确的端点、客户端参数及限定见 [BACKEND_CONTRACTS.md](BACKEND_CONTRACTS.md)。本仓库仅有客户端mock测试；以下**不得标为后台已通过**。

| ID | 优先级/方法 | 操作与输入 | 预期结果 |
| --- | --- | --- | --- |
| BE-01 | P0 S | challenge/verify有效Sol签名、坏签名、错owner、过期/replay | 正确绑定账户，过期/重放拒绝；无越权token |
| BE-02 | P0 S | protected API缺token/过期token/其他owner token | 未授权拒绝；响应不泄漏其他钱包数据 |
| BE-03 | P1 S | portfolio/defi/token-detail/asset-activity/prices正常、空、超大、坏数据 | 客户端DTO兼容，精度/价格/分页正确；无测试网混入美元总额 |
| BE-04 | P0 S | import-wallet/scan多候选、无历史、无效地址、上限 | 旧Sol派生发现不变；不上传助记词、私钥或seed |
| BE-05 | P0 S/F | solana-sender/send合法签名、错owner、坏base64、重复reference/hash | 正确确认/返回signature；认证/校验/去重符合服务契约 |
| BE-06 | P0 S | Sender响应超时/服务重启/上游已接收但断开 | 不重复付款；sender/history可核对状态，客户端不自动fallback重发 |
| BE-07 | P1 S | sender/history、received列表/详情、limit边界/越权id | 数据与账户一致；完整/空响应均能解析，无跨账户读取 |
| BE-08 | P0 S/F | 原Sol swap quote/build，坏mint、slippage、余额、过期quote、多交易 | 原行为保留；build认证正确；不把Arc发送交给Sol接口 |
| BE-09 | P0 S | child-mode、child-accounts CRUD：parent/child/foreign账户 | 权限/关联准确，儿童不能写入越权信息或提交付款 |
| BE-10 | P1 S | notifications register/unregister，换钱包/拒绝权限/旧FCM | 归属正确、幂等；注销后无错误推送到前一账户 |
| BE-11 | P1 S | airdrop profile/join/check-in重复、跨日、时区与鉴权 | 不重复奖励；原页面行为兼容 |
| BE-12 | P1 S | config/app-update/check，各platform/build/featureflags | 配置/版本兼容；不把测试分支引导到不兼容自动更新 |
| BE-13 | P1 S | contact/install-analytics边界、重复请求、错误数据 | 校验/限流；不记录秘密；写操作无不受控fallback |
| BE-14 | P1 S/M | 主后台失联、fallback健康、429/5xx/慢响应 | 只按既有策略切换；错误可读；凭据/响应属于预期环境 |
| BE-15 | P0 S | 观察Arc余额/发送网络请求；拦截payload与日志 | Arc只调用EVM RPC；没有助记词/seed/私钥/PIN传给后台或分析服务 |
| BE-16 | P1 S | 大账户/分页/并发/长时间刷新与上游限流 | 记录延迟与配额基线，无轮询风暴、资源泄漏；制定门槛后复测 |
| BE-17 | P0 S | 日志脱敏、错误回显、HTTP/TLS、环境凭据隔离 | 无密钥/签名原文/含凭据URL泄漏，staging与production分离 |
| BE-18 | P1 S | 对照部署版本/OpenAPI和本表所有调用 | 记录真实server commit、数据库迁移号、服务配置；差异反馈文档 |
| BE-19 | P2 S | 若未来增加Arc索引/价格/推送：按(chainId,address,contract,hash,logIndex)隔离 | 作为未来设计验收；当前没有这些后台实现，不虚构完成 |

## 存储、安全、平台与发布

| ID | 优先级/方法 | 操作与输入 | 预期结果 |
| --- | --- | --- | --- |
| SEC-01 | P0 A/D | 已知加密fixture正确/错误PIN解密，对比前后记录 | 已有ciphertext/nonce/salt/派生字段不改写；不产生明文session持久化 |
| SEC-02 | P0 D | 每个已发布存储版本的受控旧安装原地升级/回退评估 | 地址/资产/解锁不变；保留可恢复备份，不用真实客户数据随意验证 |
| SEC-03 | P0 D | PIN错误/更换、自动锁、后台超时、进程杀死、手机重启 | 没有锁绕过，解锁会话生命周期正确；Arc不能绕过原控制 |
| SEC-04 | P0 D | 生物识别启停/取消/失败/锁定/增删指纹、人脸、设备密码变化 | 正确fallback/失效；验证Keychain/Keystore绑定，记录已知历史缺口 |
| SEC-05 | P0 D | Android backup/restore、iOS Keychain迁移/重装，设备丢失模型 | 秘密与设备政策一致，失败可解释；禁止把未验证迁移称为安全 |
| SEC-06 | P0 A/D | 对本地存储/诊断日志/剪贴板期限/截图隐藏逐项检查 | 无新明文私钥/phrase/签名原文持久化或遥测泄漏；报告既有不足 |
| SEC-07 | P0 D | 删钱包、切钱包、儿童模式、外部托管、损坏记录 | 不跨账户读取秘密；不删除用户其它钱包；公开metadata保留政策明确 |
| PLAT-01 | P0 A | pub get/analyze/全量test | 锁定依赖可安装，静态无错误，现有测试不删且全部通过 |
| PLAT-02 | P0 M | Android liteStore/full/liteSeeker各目标构建与安装 | 可构建；STORE_MODE与featureflags独立核实；目标SKU行为正确 |
| PLAT-03 | P0 M/D | iOS无签名构建、模拟器启动、签名真机 | 编译/启动/原生插件正常；Xcode阻塞不记为代码通过 |
| PLAT-04 | P0 D | Android/iOS安全存储与生物识别、地址、RPC、签名、收发 | 完成两平台真实验收矩阵，模拟器不替代硬件安全验证 |
| PLAT-05 | P1 M/D | 离线/弱网/代理/切WiFi/蜂窝、证书异常 | 不泄漏秘密，超时可恢复，不重复交易 |
| PLAT-06 | P1 M/D | 不同OS/屏幕/版本升级、前后台长时间停留 | 记录测试设备矩阵，内存/电量/轮询无明显退化 |
| PLAT-07 | P0 M | 发布配置、应用ID/版本、签名、远程更新、RPCkey扫描 | 调试开关/QA钱包不进正式包；主网启用前另审，APK成功不等于发布成功 |
| PLAT-08 | P2 M | 原Web目标如计划交付 | 单独验证插件与密码学兼容；本轮没有Web发布结论 |

## 发布门槛与记录模板

第一版 MVP 需要：P0核心收发/存储/权限/平台通过，Android+iOS构建成功，独立私有钱包的测试网链上闭环证据、Solana回归，以及适用后台回归。P1失败必须明确修复或记录获接受的剩余风险。P2未来功能不阻塞第一版。

每个测试记录至少包含：

```text
Case ID / Code commit / Date / Tester
Platform + OS + device + flavor + STORE_MODE + feature flags
Backend commit/environment (if any) + RPC chain ID
Preconditions + public fixture IDs (no secrets)
Steps / Expected / Actual / PASS|FAIL|BLOCKED|NOT RUN
Evidence (sanitized log/screenshot/tx hash) / Issue / Next action
```

当前未满足的门槛见 [VALIDATION.md](VALIDATION.md)，不得因为这里列出了用例就宣称已完成。

## 2026-09-25 Android 自动化范围补充

现有原生集成脚本现在直接断言FE-03的横向顺序/功能模式和FE-04的两链本地图片来源；full/lite模式分别运行。该断言不替代FE-03儿童模式、FE-04所有自定义代币和断网重启等剩余变体。其它收发/历史/导入检查也只证明脚本实际覆盖的步骤；最新结果与限制见VALIDATION，不整行批量标为通过。
