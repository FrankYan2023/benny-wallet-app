# Arc 加载与页面流畅度优化 — 2026-10-03

客户端基线 `66fc383`；后台性能提交 `4e4fe7e`。修改提交见 Git 历史与 [CHANGELOG](CHANGELOG.md)，实际发布/真机结果见 [VALIDATION](VALIDATION.md)。

## 发现的问题

1. `_account` 每次重复验证Solana根地址、执行同步BIP39/BIP32 EVM派生；余额、绑定和收款调用都会触发。EVM绑定/交易签名及本地Solana后台登录签名也会占用页面线程。
2. account/assets自动释放，切换网络后重新计算和查询；backend provider监听整个WalletState，标签等无关变化也会重建客户端。
3. 后台portfolio之前，客户端先等待tokens请求；后台余额又串行查token，并先等待最长5秒的价格查询。普通USDC加载也有重复请求。
4. 刷新失败时首页替换成错误行；重试还会重新派生账户。缓存若仅按链保留，容易让不同解锁会话继承旧AsyncValue。

## 当前实现

- `EvmKeyService`增加短生命周期isolate方法；EVM地址、EIP-191绑定/消息、EIP-1559交易、EIP-712签名在后台执行。只有公开地址/签名/envelope返回，派生密钥不回到页面线程。没有新算法或密钥持久化。
- `SolanaWalletService.deriveAddress`和本地后台认证签名也在isolate中使用原有Solana库/account/change路径。MWA/SeedVault原生授权不变。异步结果使用前后检查当前账户/会话；旧存储与派生向量回归仍通过。
- `evmAddressProvider`只缓存本次解锁会话的公开EVM地址。session key包含解锁状态、root、opaque mnemonic token、custody、Solana路径；不含标签/通知/儿童列表等无关状态。每次调用仍验证临时助记词可用性；锁定、换钱包/路径/token后重算，儿童签名限制保持。
- account/tokens/assets短暂离开页面保留2分钟；资产20秒刷新，无监听时暂停，回来时过期立即刷新。`chainAssetsDisplayProvider`核对成功加载所属会话，阻止旧会话的previous值进入资产行或总额。
- 直接加载后台portfolio并读取本地公开token metadata，不再普遍先请求tokens。仅本地custom token在后台缺失时同步并重查，保留旧导币行为，不删除资产。
- 首页刷新保留资产行，显示Updating balance；失败显示上次数据与重试，总额标记不完整。首次失败仍是错误，不伪装0。重试资产请求不重新派生地址；未知余额/价格分别显示。发送估费/签名前依旧检查实时余额/费用。
- 只读GET/allowlisted读RPC针对短暂连接/超时/429/502/503/504最多重试一次；每次重新读认证和检查会话。短Retry-After被遵守，长/未知值不提前重试。401/403/错误链、广播、账户绑定写入和导币写入不自动重试，不改用公共节点。
- 后台价格/余额并行，价格预算1.2秒、失败15秒backoff、同批价格请求合并；token余额最多4并发，保留顺序。仅共享同时进行的chainId校验，之后请求重新验证。原生USDC/错误链失败终止，不继续发后续批次；自定义合约失败明确标不可用。详见 [后台记录](https://github.com/FrankYan2023/benny-wallet/blob/main/docs/ARC_PERFORMANCE_2026_10_03.md)。

## 变更位置

- `lib/core/chains/evm/{evm_key_service,evm_adapter}.dart`、`core/chains/chain_backend_client.dart`、`core/chains/solana_message_signer.dart`、`core/network/backend_session_manager.dart`。
- `features/auth/data/solana_wallet_service.dart`、`features/multichain/providers/multichain_providers.dart`、`presentation/portfolio_network_widgets.dart`。
- Send填写/选币与资产详情统一读取经过会话检查的资产状态；发送/广播协议保留。
- 新增EVM后台计算5项、Solana后台认证2项、加载/缓存/会话/故障恢复5项；backend client新增只读重试4项。已有发送测试改为等待真实isolate完成，未删除测试/放宽发送次数或签名向量断言。
- companion后台修改assets/rpc/service与新增5项性能用例；没有数据库/schema/config/indexer修改。

## 实际验证和限制

- Flutter相关35项加载/客户端/发送回归通过；完整套件125项中124通过、1个既有Swap文本本地化检查失败。新增16项全部通过，签名/派生/旧加密记录向量通过。
- `flutter analyze --no-pub lib test integration_test`通过；源码与补充测试范围正确，不拿忽略的第三方build缓存当成应用代码结果。
- 后台28项测试/TypeScript build通过，5项新用例检查并发上限、价格等待独立、共享请求、错误链与USDC失败停止；没有用真实钱包/资金。
- Seeker Android16普通full debug生产API更新：13.2秒构建、5.5秒安装、120ms同步，启动成功、调试连接保留。保留已有Full钱包和独立Lite；没有清数据。初始冷启动/解锁与连续切链还需持有人自行解锁后的观察，不声称已经获得FPS/延迟百分比。
- 当前没有iOS重建、资金/推送/硬件签名验收。此前独立历史索引部分backfill错误未在本轮修改；接口性能通过不能代替历史完整性通过。详细待测见 [TEST_PLAN](TEST_PLAN.md) 和 [ANDROID_PHYSICAL_DEBUG](ANDROID_PHYSICAL_DEBUG.md)。
