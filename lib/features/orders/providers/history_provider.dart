import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_model.dart';
import '../data/orders_repository.dart';

class HistoryState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  HistoryState({
    this.orders = const [],
    this.isLoading = true,
    this.error,
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return HistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    Future.microtask(_fetch);
    return HistoryState();
  }

  Future<void> _fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      final orders = await repo.fetchHistory(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void search(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    _fetch();
  }

  Future<void> refresh() => _fetch();
  
  Future<void> exportCsv() async {
    final repo = ref.read(ordersRepositoryProvider);
    // Hardcoded branch for now
    await repo.exportCsv(branchUuid: 'default');
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
