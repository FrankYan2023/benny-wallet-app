import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/chains/chain_backend_client.dart';
import '../../../core/chains/chain_models.dart';
import 'multichain_store.dart';

class BackendHistoryController
    extends StateNotifier<AsyncValue<ChainHistoryPage>> {
  BackendHistoryController(this.client, this.store, this.account)
    : super(const AsyncLoading()) {
    unawaited(refresh());
  }
  final ChainBackendClient client;
  final MultichainStore store;
  final Future<ChainAccount> account;
  Timer? _timer;
  bool _busy = false;
  bool loadingMore = false;

  Future<void> refresh() async {
    if (_busy) return;
    _busy = true;
    _timer?.cancel();
    try {
      final current = await account;
      final page = await client.history();
      final local = await store.submissions(current);
      final previous = state.valueOrNull;
      final items = mergeChainHistory([
        ...page.items,
        ...previous?.items ?? [],
        ...local,
      ]);
      if (mounted)
        state = AsyncData(
          ChainHistoryPage(
            items: items,
            nextCursor: previous == null || !previous.backfillComplete
                ? page.nextCursor
                : previous.nextCursor,
            backfillComplete: page.backfillComplete,
          ),
        );
    } catch (error, stack) {
      if (mounted) state = AsyncError(error, stack);
    } finally {
      _busy = false;
      if (mounted) _timer = Timer(const Duration(seconds: 15), refresh);
    }
  }

  Future<void> loadMore() async {
    final previous = state.valueOrNull;
    if (_busy || previous?.nextCursor == null) return;
    _busy = loadingMore = true;
    try {
      final page = await client.history(cursor: previous!.nextCursor);
      if (mounted)
        state = AsyncData(
          ChainHistoryPage(
            items: mergeChainHistory([...previous.items, ...page.items]),
            nextCursor: page.nextCursor,
            backfillComplete: page.backfillComplete,
          ),
        );
    } finally {
      _busy = loadingMore = false;
      _timer?.cancel();
      if (mounted) _timer = Timer(const Duration(seconds: 15), refresh);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
