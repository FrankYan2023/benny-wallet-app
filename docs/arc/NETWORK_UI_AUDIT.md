# 网络图标与交易历史页面检查

日期：2026-09-29；基线：`595efa2`。仅修改既有 Flutter 客户端，未修改后端、网络配置或钱包存储。

## 2026-10-03 Send 交互按 Solana 统一（当前实现）

Arc移除独立币种下拉和首页内嵌发送表单，改为与原Solana相同的持仓币种列表 → 专属填写页 → 独立确认页 → 发送中/结果。填写和确认共用原Solana展示组件，网络图标持续可见；币种行保留链角标、仅可用正余额进入列表，零余额同原Solana空态。资产详情Send直接打开对应币种填写页。

因此当前实际下拉入口只剩首页网络筛选与共享网络选择，继续复用同宽WalletDropdown；发送币种选择以TokenRow列表完成。旧截图/上一轮宽度规则保留历史，不代表仍有Arc币种下拉。扫码显示所选网络，Arc显式错误链QR拒绝，原Solana地址提取保留。

[币种列表](evidence/arc-send-assets-parity-20261003.png)、[填写页](evidence/arc-send-compose-parity-20261003.png)、[确认页](evidence/arc-send-review-parity-20261003.png)为390px公开无资金fixture；生产Android联调使用独立无资金钱包，仅验收空列表与导航。[Send对齐说明与测试](SEND_UX_PARITY.md)。

## 2026-10-03 下拉框统一同宽（上一轮）

按最新反馈，展开菜单与触发选择框等宽、左右对齐，替代之前固定224px的独立菜单。所有实际下拉框统一使用 `core/widgets/wallet_dropdown.dart` 的 WalletDropdown：按父布局读取控件宽度，下方8px展开、22px圆角、细边框无重阴影，选中项暖色底与勾号。

| 实际下拉框 / 页面 | 宽度与覆盖 | 源码 |
| --- | --- | --- |
| 网络选择 / Send、Receive、共享活动页 | 框与页面内容等宽，菜单与框等宽 | chain_widgets.dart → WalletDropdown |
| 首页网络筛选 | 按钮和菜单均120px，保留地球/链图标、网络名称和勾号；全部网络文字可换行 | portfolio_network_widgets.dart → WalletDropdown |
| Arc发送币种选择 | 选择框与卡片内容等宽，菜单随框宽度；保留资产切换及忙碌禁用 | network_send_page.dart → WalletDropdown |
| 设置语言 / 自动锁定、Swap选择面板 | 使用底部面板/对话框/独立币种页面，不是下拉菜单，保持现有交互 | settings_page.dart、swap_page.dart |

检查范围：客户端全部 lib 和 packages/design_system/lib；搜索 DropdownButton、DropdownMenu、PopupMenuButton、showMenu、MenuAnchor、MenuItemButton，当前仅统一组件含实际菜单实现。14项现有组件测试通过、7个受影响文件静态分析通过。已有两份集成测试同步首页选项匹配，本轮未运行设备集成测试。

人工查看390px公开组件fixture截图：[接收网络菜单](evidence/receive-matched-width-menu-20261003.png)、[首页筛选菜单](evidence/home-matched-width-menu-20261003.png)、[发送币种菜单](evidence/send-asset-matched-width-menu-20261003.png)。首页截图为菜单/资产组合fixture，并非完整真实首页；Arc Testnet仅是测试数据，Android调试仍使用既有生产主网接口。先前截图和历史验证保留在 CHANGELOG / VALIDATION。

## 一致规则

- 明确显示网络身份的选择项和标签均使用链图标 + 名称，全部网络使用地球图标。协议说明、错误提示和费用字段等普通句子不插入装饰图标。
- `core/widgets/network_badge.dart` 提供 NetworkIcon / NetworkBadge；图片取自 ChainConfig 的本地图标资源，离线可用，缺失图片使用地球回退，名称保留。
- `ChainNetworkIdentity` 按记录 chainId 解析，独立于首页筛选/收发网络；未知链显示原 chainId 与地球，不猜测成已知链。
- 既有 Solana-only API/模型记录明确标记 Solana，不改写旧历史、不执行数据迁移；Arc 活动与通知使用自己的 chainId。

## 页面覆盖

以下源码路径相对 `apps/wallet_client_flutter/lib/`。

| 页面/状态 | 本次检查与修改 | 主要源码 |
| --- | --- | --- |
| 首页筛选 | All 地球保留；菜单复用统一组件；选中 Solana/Arc 后按钮也有链图标；拓宽按钮容纳图标 | features/multichain/presentation/portfolio_network_widgets.dart |
| 首页/发送资产列表 | 已有 TokenRow 链角标继续保留；Arc 加载/错误网络标签补图标 | portfolio_network_widgets.dart、features/portfolio/presentation/pages/portfolio_page.dart、features/send/presentation/pages/send_page.dart |
| 发送/接收/活动网络下拉 | 选中值和展开选项均图标 + 名称 | features/multichain/presentation/chain_widgets.dart |
| 接收二维码/代币导入/网络资产详情 | ChainNetworkLabel 统一补图标，测试网标识保留 | chain_widgets.dart、token_import_page.dart、features/asset_detail/presentation/pages/asset_detail_page.dart |
| Solana 发送编辑/确认 | 编辑页既有共享标签自动覆盖；确认页 Network 行显示图标 | features/send/presentation/pages/send_compose_page.dart、send_confirm_page.dart |
| Arc 发送确认 | 明确显示准备交易账户所属网络 + 图标 | features/multichain/presentation/network_send_page.dart |
| Solana 发送结果/处理中 | 增加网络标识 | features/send/presentation/pages/send_execute_page.dart |
| Solana 资产信息/历史 | Network 字段替换纯文字；每个活动条目显示 Solana 图标和名称 | features/asset_detail/presentation/pages/asset_detail_page.dart |
| Solana 发送历史/详情 | 列表逐笔显示网络，详情 Network 行图标化 | features/send/presentation/pages/send_history_page.dart |
| Solana 收款历史/详情/时间线 | 列表、详情字段与时间线显示对应标识 | features/notifications/presentation/pages/notifications_page.dart |
| Arc 活动/交易详情 | 列表状态附近和展开详情均按交易 chainId 显示；修复新版 Flutter 的 ExpansionTile 点击效果背景遮挡断言 | features/multichain/presentation/network_page.dart |
| 收款通知列表/详情 | 有 chainId 按记录显示；旧 incoming_funds 无 chainId 按旧 Solana 来源显示；未知链不冒充 Solana | features/notifications/presentation/pages/notifications_page.dart |
| 钱包导入账户选择 | 原通用 hub 图标换为 Solana 标识 | features/onboarding/presentation/pages/import_wallet_selection_page.dart |
| Swap / xStocks | 标题配 Solana 标识；付款/收款币种选择页、确认页、处理/结果页补网络标识；Arc Swap 仍不支持，首次提示保留 | features/swap/presentation/pages/swap_page.dart、swap_review_page.dart、swap_execute_page.dart |

## 验证与证据

- 20 项相关测试通过：multichain widgets 14 + swap scope 3 + notification 3。
- 新增历史回归：旧 Solana 发送历史列表/详情、Arc 活动列表/详情不随当前选中链改变、未知链不误标。
- 全 lib 与修改测试静态分析通过；Android full debug 构建 23.5 秒、安装 721 ms，普通 main.dart 启动并保留调试器；生产 API https://api.gobennyapp.com。
- 两张组件截图已人工查看：图标、网络名称、状态、展开详情可见。截图使用公开无资金 fixture；Arc Testnet 仅是此组件测试数据，当前模拟器连接仍为既有主网后台。
- [Solana 历史](evidence/network-solana-history-20260929.png)；[Arc 活动展开](evidence/network-arc-activity-20260929.png)。
- 未进行真实资金交易、后台重部署、iOS 重建或所有页面真机逐屏验收。已有菜单文字点击警告和 310 项中文缺失提示保留；不影响本轮测试通过。工具链自动写入的 Gradle 迁移已恢复，不混入 UI 提交。
