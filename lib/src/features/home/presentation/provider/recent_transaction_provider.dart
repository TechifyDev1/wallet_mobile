import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/recent_transaction_response.dart';
import 'recent_transaction_repo_provider.dart';

final recentTransactionProvider =
    AsyncNotifierProvider<
      RecentTransactionNofier,
      List<RecentTransactionResponse>
    >(() {
      return RecentTransactionNofier();
    });

class RecentTransactionNofier
    extends AsyncNotifier<List<RecentTransactionResponse>> {
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  @override
  Future<List<RecentTransactionResponse>> build() async {
    final repo = ref.read(recentTransactionRepoProvider);
    final response = await repo.getRecentTx(page: 0);
    _currentPage = 0;
    _hasMore = !response.isLast;
    return response.content;
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore || _isFetchingMore) return;

    final repo = ref.read(recentTransactionRepoProvider);
    final nextPage = _currentPage + 1;

    _isFetchingMore = true;
    // Trigger a rebuild so the UI sees _isFetchingMore = true
    state = state.whenData((data) => data);

    final response = await repo.getRecentTx(page: nextPage);
    _currentPage = nextPage;
    _hasMore = !response.isLast;
    _isFetchingMore = false;

    final previousData = state.value ?? [];
    state = AsyncValue.data([...previousData, ...response.content]);
  }

  Future<void> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(recentTransactionRepoProvider)
          .getRecentTx(page: 0);
      _hasMore = !response.isLast;
      return response.content;
    });
  }
}
