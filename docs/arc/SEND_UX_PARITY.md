# Send 交互对齐 Solana

日期：2026-10-03。基线 `a9c9fb3` 加本轮客户端改动；最终提交与执行证据见 [CHANGELOG](CHANGELOG.md) / [VALIDATION](VALIDATION.md)。只涉及已有 Flutter App，不增加独立 Arc 钱包或后台页面。

## 用户目标与原问题

以原 Solana Send 的交互为准，统一两条链的选币、填写、确认和结果体验。原 Solana 是“发送资产列表 → 点击具体币种 → 地址/金额/扫码/Max → Next → 独立确认页 → Send → 发送结果”。此前 Arc 在共享Send页内直接放币种下拉、地址、金额以及 `Estimate fee & review` 大表单，并在该表单内切换确认；还显示了不必要的合约地址。即使后台协议不同，用户完成同一个发送操作的路径也不应因此改变。

## 当前交互

1. **共享 Send 列表**：先选择网络，Solana与Arc都用原有TokenRow显示余额大于零的可发送资产；币头像保留链角标。零余额显示原 `sendNoAssets` 空态，余额读取失败显示可重试错误，不能伪装为零余额。网络菜单仍与触发框同宽。
2. **点币进入填写页**：币种和网络固定为列表中点选值，标题 `Send <symbol>`。保留网络图标/名称、币头像、收款地址、扫码、金额、Max、估算美元/可用余额以及底部 Cancel / Next。Arc不再使用币种下拉，也不在填写页另加网络切换。错误或已删除的资产ID显示资产不存在，不能悄悄换成另一个币。
3. **Next估费后打开独立确认路由**：输入有效地址和金额、余额足够才准备交易。确认复用原Solana的金额标题、信息面板和 Cancel / Send。Arc显示完整收款地址、网络标识、预计费用、最高费用，以及适用时的代币合约，以支持资产身份核对；费单位为USDC。未知价格或测试网不伪造美元估值。
4. **Cancel / 返回**：回到原填写页，保留该笔地址和金额；Next/Max进行中、签名/广播进行中禁止重复操作及返回。Next只准备交易，不签名、不广播。
5. **显式Send才签名广播**：显示发送中与结果，提供交易浏览器、对应网络活动和关闭回首页入口。响应不确定时提示先检查活动，保留已知交易hash，不展示假失败并自动重发。广播成功代表已提交，最终链上状态继续由对应网络活动/回执查询判断。

资产详情Send直接打开该资产的固定填写页；旧 `/networks/:chainId/send` 链接兼容进入共享Send列表。Solana原Compose / Confirm / Execute路径和业务逻辑保留。

## 共享组件与链服务分工

`features/send/presentation/widgets/send_widgets.dart` 从原Solana页面抽出六个组件：`SendInputCard`、`SendAmountCard`、`SendTokenAvatar`、`SendBottomActionRow`、`SendInfoRowData`、`SendReviewContent`。Solana页面与Arc页面引用同一展示实现，默认圆角、间距、按钮及文字样式保持原Solana。完整Arc地址可通过`maxLines: null`显示；Solana原有紧凑地址显示不变。

UI仅负责取当前链资产、输入、路由及展示。Solana仍通过现有Solana钱包服务估费和发送；EVM协议、BigInt金额、USDC原生/ERC-20别名和手续费精度留在`EvmAdapter`，确认有效期、会话与重复提交限制留在`ChainTransferController`。未修改助记词/密钥派生、PIN存储、后台接口、数据库或Arc网络常量。

## Arc Max 的准确含义

- `ChainAdapter.maximumTransferAmount`为链服务提供最大可发送数量接口；本轮EVM实现由`ChainTransferController.maximumAmount`调用，在计算前后检查当前钱包、解锁和权限。既有Solana Max保持原计算，不因共享组件改变。
- Arc原生USDC与其ERC-20别名使用原生18位余额保留费用，按所选资产精度（通常USDC 6位）向下取整；手续费dust不先截成6位，也不使用double参与签名金额计算。
- 使用**最高网络费**保留预算；先探测最小单位的费用，再以实际候选全额重新估费。实际gas或费率上涨时提高预算重算，最多4轮；仍不稳定则明确失败，不填入可能导致余额不足的金额。
- 自定义ERC-20读取最新完整代币余额，另检查原生USDC是否足够支付该全额transfer的最高手续费。不能把币余额当成gas余额。
- Max仍要求该网络的有效收款地址。Max成功只填金额，之后Next仍重新准备并核对费用，再显式Send；余额、网络或权限异常时不签名。

## 扫码与安全边界

扫码以用户已经选定的ChainConfig解析，不根据二维码静默切网。`recipient_decoder.dart`对EVM接受有效0x收款地址及普通 `ethereum:<address>@<chainId>` 收款URI；明确chainId必须匹配，拒绝Solana地址、错误链、任意文本夹带地址，以及以合约为首地址的ERC-20 `/transfer` URI，避免把合约误当收款人。这里只提取收款地址，未实现支付URI金额或复杂合约动作自动填充。

Solana的原始地址、原支付URI和既有二维码提取行为继续保留。扫码只返回地址，不能发起准备、签名或广播。

既有安全限制继续生效：儿童模式与锁定会话不可发送；无本地根/不支持的托管不能获得伪造EVM签名能力；确认绑定钱包与链，2分钟过期、单次消费；签名前/签名后/广播前检查会话，按网络账户串行化；提交前保存本地计算hash；广播响应丢失不自动重发。确认取消不会消费密钥或发送交易。

## 主要变更文件

以下路径相对 `apps/wallet_client_flutter/`：

| 文件 | 作用 |
| --- | --- |
| `lib/features/send/presentation/pages/send_page.dart` | 共享两链可发送资产列表与空态 |
| `lib/features/multichain/presentation/network_send_page.dart` | 固定资产填写、独立Arc确认与提交状态 |
| `lib/features/send/presentation/widgets/send_widgets.dart` | 抽取原Solana共享展示组件 |
| `lib/features/send/presentation/pages/send_compose_page.dart` | 复用共享填写组件，保留原业务 |
| `lib/features/send/presentation/pages/send_confirm_page.dart` | 复用共享确认组件，保留原业务 |
| `lib/features/send/presentation/pages/scan_address_page.dart` | 按明确网络验证扫码结果 |
| `lib/core/chains/recipient_decoder.dart` | 无UI的链感知收款二维码解析 |
| `lib/core/chains/chain_adapter.dart` / `evm/evm_adapter.dart` | 最大数量接口与BigInt费用预算 |
| `lib/features/multichain/data/chain_transfer_controller.dart` | Max前后会话保护 |
| `lib/app/router.dart` | 填写/确认路由、旧链接兼容及守卫 |
| `lib/features/asset_detail/presentation/pages/asset_detail_page.dart` | 资产详情进入固定资产填写页 |
| `test/core/chains/{evm_adapter_test,recipient_decoder_test}.dart` | Max精度/网络/QR边界 |
| `test/features/multichain/{widgets_test,chain_transfer_controller_test}.dart` | 路径、校验、确认、权限、重复提交 |
| `integration_test/arc/{arc_backend_ui_test,arc_emulator_smoke_test}.dart` | 无资金设备脚本对齐新列表/空态预期 |

## 自动化与人工测试矩阵

完整注册名称与计数见 [AUTOMATED_TESTS](AUTOMATED_TESTS.md)，发布需求见 [TEST_PLAN](TEST_PLAN.md)。下表状态只对应本轮明确执行范围，不扩展为整行设备/资金验收。

| 检查 | 自动化结果 | 仍需人工/设备/受控资金验证 |
| --- | --- | --- |
| 两链网络选择、Arc资产列表、零余额、币种固定、丢失资产拒绝 | 18项组件套件通过中的相关断言 | 生产/真机有余额列表、长名称、慢网和刷新 |
| 错地址、零/负金额、余额不足、Next、Cancel保留输入、显式Send | 18项组件套件通过中的相关断言；不真实广播 | 私有测试网钱包资金收发、链上金额与余额变化 |
| 签名/广播中重复Send与返回限制 | 组件/控制器通过 | Android返回手势、后台切换、真机锁屏 |
| USDC 6/18精度、18位大余额、费用变化、ERC-20 Max、错误网/不足gas | EVM/控制器中新增8项通过；所属38项套件通过 | 真实gas/余额变化下重新确认、非零BENNY全额 |
| EVM原始地址/正确URI、错误链、合约transfer URI；旧Solana二维码 | 新增3项解析测试通过 | 相机权限、真实二维码摄像头扫描、中文/英文键盘 |
| Solana adapter原行为 | 8项通过，计入38项 | 原Solana真机收发/扫码/Max/确认回归 |
| 存量密钥及账户 | 原存储回归包含在全量运行中；未改格式 | 受控旧版本原地升级与生物识别设备回归 |
| 完整Flutter本地套件 | 109项中108通过、1既有本地化失败 | 既有Swap提示应迁到本地化资源后重跑 |
| 静态分析 | `lib test integration_test`通过 | 全项目75项第三方构建缓存问题不属源代码通过范围 |
| Android普通调试更新 | 生产API普通调试热重启7879ms成功 | 生产主网5042无资金模拟器QA105秒通过；物理设备未重跑 |
| iOS | 本轮未重跑 | iOS构建、模拟器/真机完整发送路径 |

## 本轮执行结果与限制

已通过18项组件、38项EVM/Solana/控制器及3项QR解析检查。完整测试不是全绿：108通过、1既有Swap提示本地化字面量失败；该失败路径未在本轮发送改动中修改。源代码范围静态检查通过；全项目分析的75项来自忽略的iOS第三方构建缓存。Android普通生产API调试已热重启；专用模拟器使用真实生产API `https://api.gobennyapp.com`、Arc主网5042完成105秒无资金QA（1项testWidgets + tearDownAll，runner +2通过），没有使用HTTP fixture或直接RPC替代。覆盖真实PIN/安全存储、All/Solana/Arc切换、收款QR/复制/历史、两链新Send零余额空列表/切换以及metadata查询/导入去重。该客户端流程可能绑定此QA钱包公开账户或同步导入代币元数据，不上传根密钥。集成构建21.1秒、安装7.5秒；随后普通`main.dart`构建11.3秒、安装5.2秒，恢复正常调试连接。

本轮不增加后台部署或数据库变更，不重跑iOS构建，不给公开QA钱包注资，不执行真实签名广播。后续受控资金与真机验证必须使用独立私有测试钱包；用户钱包不能清数据或卸载来完成UI回归。
