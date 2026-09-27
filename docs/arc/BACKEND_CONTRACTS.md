# 后台接口与联调边界

## 当前架构（2026-09-26）

本轮实际检查并修改独立后台仓库 `FrankYan2023/benny-wallet` 的 `apps/wallet_api`。新增 API、表、鉴权/签名校验、持久化历史与通知细节见 [后台权威实施文档](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_MULTICHAIN.md)、[后台测试矩阵](https://github.com/FrankYan2023/benny-wallet/blob/arc/docs/ARC_TEST_PLAN.md)。已做本地测试；远程部署和数据库迁移未执行。

```text
共用 Solana UI → SolanaAdapter / 原 service → 原 Benny 后台 → Solana/Helius
共用 Arc UI → EvmAdapter + ChainBackendClient → /v1/arc-rpc → Arc EVM 节点
           → 账户证明/资产/云 token/历史 API → Supabase + 后台索引 → 共用 FCM
```

Arc 沿用原 Solana 根地址的 Bearer 会话，但独立要求 EVM 地址所有权证明。`0x` 地址不会冒充 Solana owner；地址绑定后以 owner + chain + EVM address 隔离数据。助记词和交易签名留在手机；后台仅校验、记录哈希并转发已签名交易。

新增 `/v1/chains/arc/{config,health,account,tokens,portfolio,activity}` 与账户 challenge/verify；需要 Bearer，除 config 外还须匹配 `X-Chain-Id`。客户端不向公共 RPC 泄露钱包 API token，也不会在主网失败后切到测试网。

以下原接口表保留为前期从客户端收集的 Solana 回归范围；具体服务端实现、部署权限与集成结果必须分别核实。

## 从客户端发现的真实端点

“认证”表示客户端使用 authenticated request helper，不是对服务端权限正确性的保证。响应以当前 DTO/解析代码为准；这里只写可确认的关键字段，未臆造 server 错误码。

| 方法/路径 | 关键请求 / 返回 | 客户端认证 | 对应测试 |
| --- | --- | --- | --- |
| POST `/v1/auth/challenge` | ownerAddress → challenge DTO | 否 | BE-01 |
| POST `/v1/auth/verify` | ownerAddress, challenge, signature → session DTO | 否 | BE-01/02 |
| POST `/v1/portfolio` | ownerAddress → portfolio map | 否 | BE-03 |
| POST `/v1/defi-positions` | ownerAddress → positions map | 否 | BE-03 |
| POST `/v1/import-wallet/scan` | addresses, fallbackAddresses → items | 否 | BE-04 |
| POST `/v1/token-detail` | mintAddress → detail map | 否 | BE-03 |
| POST `/v1/asset-activity` | ownerAddress, mintAddress, limit → activity map | 否 | BE-03/07 |
| GET `/v1/tokens`、`/v1/tokens/search` | search 的 q → items | 否 | BE-03 |
| POST `/v1/prices` | symbols → items/PriceQuote | 否 | BE-03 |
| GET `/v1/config` | → RemoteAppConfig | 否 | BE-12 |
| GET `/v1/app-update/check` | build, platform → update | 否 | BE-12 |
| POST `/v1/swap/quote` | inputMint, outputMint, amount, slippageBps → quote map | 否 | BE-08 |
| POST `/v1/swap/build` | ownerAddress + quote输入 + priorityPreset → build map | 是 | BE-08 |
| POST `/v1/solana-sender/send` | encodedTransaction + 可选txType/fromMint/toMint/amount/referenceId/destinationAddress → signature | 是 | BE-05/06 |
| GET `/v1/solana-sender/history` | limit → items | 是 | BE-07 |
| GET `/v1/wallet-profile` | → wallet profile DTO | 是 | BE-02/09 |
| PUT `/v1/wallet-profile/child-mode` | childModeEnabled + 已加密cipherText/nonce/salt | 是 | BE-09 |
| DELETE `/v1/wallet-profile/child-mode` | 清除儿童模式设置 | 是 | BE-09 |
| POST `/v1/child-accounts` | childName, childAddress | 是 | BE-09 |
| PATCH `/v1/child-accounts/by-address/{address}` | childName, childAddress | 是 | BE-09 |
| DELETE `/v1/child-accounts/by-address/{address}` | 删除关联 | 是 | BE-09 |
| GET `/v1/airdrop/profile` | → profile map | 是 | BE-11 |
| POST `/v1/airdrop/join`、`/v1/airdrop/check-in` | ownerAddress | 是 | BE-11 |
| POST `/v1/notifications/register-device` | appVersion, buildNumber, fcmToken, installId, notificationsEnabled, platform, 可选permissionStatus | 是 | BE-10 |
| POST `/v1/notifications/unregister-device` | appVersion, buildNumber, installId, platform, 可选fcmToken/permissionStatus | 是 | BE-10 |
| GET `/v1/notifications/received` | limit → items | 是 | BE-07 |
| GET `/v1/notifications/received/{id}` | → item | 是 | BE-07 |
| POST `/v1/contact` | email, message, pagePath, source | 否 | BE-13 |
| POST `/v1/install-analytics` | 版本、平台、locale、时间、installId、钱包数量/设置统计 | 否 | BE-13/17 |

部分写操作（Sender、contact、analytics、儿童设置、空投、设备注册等）显式关闭 backend fallback。不得为了提高“成功率”把它们改成自动跨后台重复写。重复请求的服务端幂等语义仍需 BE-05/06/09/10/11/13 验证。

## Arc RPC 合约

| 方法组 | 当前用途 | 主要验收 |
| --- | --- | --- |
| `eth_chainId` | 每个选中RPC/备用RPC与签名链一致 | 错链停止，不跳过验证 |
| `eth_getBalance`、`eth_call`、`eth_getCode` | native balance、ERC20 metadata/balance、合约验证 | 18/6精度、恶意返回、USDC去重 |
| `eth_estimateGas`、`eth_gasPrice`、`eth_feeHistory`、`eth_getTransactionCount` | gas/fee/nonce | floor、gas margin、过期nonce、防精度丢失 |
| `eth_sendRawTransaction` | 用户确认后的已签EIP1559交易 | 单次广播，丢失响应可追踪hash，不自动重发 |
| `eth_getTransactionByHash`、`eth_getTransactionReceipt` | 交易状态与真实费用 | null未知、reverted失败、Arc finality |
| `eth_blockNumber`、`eth_getBlockByNumber`、`eth_getLogs` | 时间/最终性/近期原生和ERC20活动 | 连续100块分段、1000块窗口、重复事件处理 |

RPC端点、链ID、预部署合约均在 `arc_chain_config.dart`，不在UI中。具体方法以 `EvmAdapter` 为准。主网接入条件/费用规则是需要重新核对的外部事实，不能仅靠本表作为最新官方规范。

## 后台人员执行前需要的资料

1. 独立后台仓库/commit、staging base URL、部署版本、数据库 schema/migration 号和真实 API 文档。
2. 测试账户/权限、限流与上游RPC配置、可观测日志；仅传安全的凭据引用，不提交秘密。
3. 两类报告分开：客户端与API的契约测试；服务端权限/幂等/安全/负载测试。
4. 根据 [TEST_PLAN.md](TEST_PLAN.md) BE-01…BE-19 和共用端到端用例，保存实际请求/脱敏响应、预期、实际、环境、失败issue。

当前没有可声明的服务端测试结果。未来新增 Arc 后台服务时，先定义 network-scoped IDs、重复事件幂等键、跨网络 USDC去重/定价、分页与同步滞后语义、鉴权和通知账户归属；然后增加实际服务端测试与部署记录。
