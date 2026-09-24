import '../../notifications/presentation/pages/notifications_page.dart';
import '../../../core/chains/solana_adapter.dart';
import 'chain_widgets.dart';

/// Keeps the existing Solana receipt feed while new networks use their own
/// normalized activity. Pages do not need to know protocol families.
String receiveHistoryPath(String chainId) =>
    _receiveHistoryRoutes[chainId] ?? networkPath(chainId);

const _receiveHistoryRoutes = {
  SolanaAdapter.networkId: ReceivedHistoryPage.routePath,
};
