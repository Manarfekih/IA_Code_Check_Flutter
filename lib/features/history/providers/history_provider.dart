import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

final historyServiceProvider =
    Provider<HistoryService>((ref) => HistoryService());

class HistoryState {
  final List<HistoryItem> items;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<HistoryItem>? items,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isEmpty => items.isEmpty;
  int get count => items.length;
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryService _service;

  HistoryNotifier(this._service) : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final items = _service.getAllAnalyses();
      state = state.copyWith(
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addAnalysis(HistoryItem item) async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.saveAnalysis(item);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.deleteAnalysis(id);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteAllItems() async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.deleteAllAnalyses();
      await loadHistory();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);

    final results = query.isEmpty
        ? _service.getAllAnalyses()
        : _service.searchAnalyses(query);

    state = state.copyWith(items: results);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(ref.watch(historyServiceProvider)),
);
