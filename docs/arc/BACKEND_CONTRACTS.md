# 后台接口与联调边界

## 已确认与未确认

本分支只修改 `benny-wallet-app`。没有修改/部署 `FrankYan2023/benny-wallet` 后台，也没有数据库迁移。本清单来自客户端实际调用，不是经服务端源码/OpenAPI审核的完整服务规范。不要把客户端 mock 通过等同于服务器通过。

客户端来源：
- [`api_client.dart`](../../apps/wallet_client_flutter/lib/core/network/api_client.dart)
- [`wallet_auth_api_client.dart`](../../apps/wallet_client_flutter/lib/core/network/wallet_auth_api_client.dart)
- [`backend_session_manager.dart`](../../apps/wallet_client_flutter/lib/core/network/backend_session_manager.dart)
- [`backend_endpoint_fallback.dart`](../../apps/wallet_client_flutter/lib/core/network/backend_endpoint_fallback.dart)
- [`evm_rpc.dart`](../../apps/wallet_client_flutter/lib/core/chains/evm/evm_rpc.dart)

## 两条调用路径

```text
原 Solana UI → 既有 repository/API client → Benny 后台 / Solana RPC
                                      → Solana Sender（签名交易，非私钥）
共用 Arc UI → ChainAdapter / EvmAdapter → 经 eth_chainId 校验的 Arc JSON-RPC
                                      → 本地 metadata/submission store
```

Arc 不需要把 0x 地址伪装成 Solana `ownerAddress`，不调用 Solana Sender 广播 EVM 交易，不要求后台持有助记词。既有后台认证目前沿用 Solana 身份流程；本轮没有新增 SIWE/EVM 登录。未来若要增加 Arc 价格、完整历史索引或推送，需独立设计链/账户隔离与身份绑定。

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
