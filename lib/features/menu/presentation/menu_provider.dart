import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/menu_model.dart';
import '../data/menu_repository.dart';

class MenuState {
  const MenuState({
    this.categories = const [],
    this.items = const [],
    this.isLoading = true,
    this.error,
    this.syncingItems = const {},
  });

  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final bool isLoading;
  final String? error;
  /// Item UUIDs currently syncing (debounced writes)
  final Set<String> syncingItems;

  List<MenuCategory> get categoriesWithItems {
    return categories.map((cat) {
      final catItems = items.where((i) => i.category == cat.uuid).toList()
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      return cat.withItems(catItems);
    }).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  MenuState copyWith({
    List<MenuCategory>? categories,
    List<MenuItem>? items,
    bool? isLoading,
    String? error,
    Set<String>? syncingItems,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      syncingItems: syncingItems ?? this.syncingItems,
    );
  }
}

class MenuNotifier extends Notifier<MenuState> {
  final Map<String, Timer> _debounceTimers = {};

  @override
  MenuState build() {
    ref.onDispose(() {
      for (final t in _debounceTimers.values) {
        t.cancel();
      }
    });
    Future.microtask(_load);
    return const MenuState();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(menuRepositoryProvider);
      final cats = await repo.fetchCategories();
      final items = await repo.fetchItems();
      state = state.copyWith(
        categories: cats,
        items: items,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load menu.',
      );
    }
  }

  /// Optimistic availability toggle with 500ms debounce
  void toggleAvailability(String uuid) {
    // Optimistic update
    final updated = state.items.map((item) {
      if (item.uuid == uuid) return item.copyWith(available: !item.available);
      return item;
    }).toList();
    state = state.copyWith(
      items: updated,
      syncingItems: {...state.syncingItems, uuid},
    );

    // Debounce the actual API call — 500ms
    _debounceTimers[uuid]?.cancel();
    _debounceTimers[uuid] = Timer(const Duration(milliseconds: 500), () async {
      try {
        final repo = ref.read(menuRepositoryProvider);
        final confirmed = await repo.toggleAvailability(uuid);
        _replaceItem(confirmed);
      } catch (_) {
        // Rollback on failure
        final rollback = state.items.map((item) {
          if (item.uuid == uuid) return item.copyWith(available: !item.available);
          return item;
        }).toList();
        state = state.copyWith(items: rollback);
      } finally {
        final syncing = Set<String>.from(state.syncingItems)..remove(uuid);
        state = state.copyWith(syncingItems: syncing);
      }
    });
  }

  /// Update price with 1.5s autosave debounce
  void updatePrice(String uuid, int newPriceMinor) {
    // Optimistic
    final updated = state.items.map((item) {
      if (item.uuid == uuid) return item.copyWith(basePriceMinor: newPriceMinor);
      return item;
    }).toList();
    state = state.copyWith(items: updated);

    // 1.5s debounce
    _debounceTimers['price_$uuid']?.cancel();
    _debounceTimers['price_$uuid'] = Timer(const Duration(milliseconds: 1500), () async {
      try {
        final repo = ref.read(menuRepositoryProvider);
        final confirmed = await repo.updatePrice(uuid, newPriceMinor);
        _replaceItem(confirmed);
      } catch (_) {
        // On fail, no rollback (user sees their value; next refresh corrects)
      }
    });
  }

  void _replaceItem(MenuItem item) {
    final updated = state.items.map((i) => i.uuid == item.uuid ? item : i).toList();
    state = state.copyWith(items: updated);
  }

  Future<void> refresh() => _load();
}

final menuProvider = NotifierProvider<MenuNotifier, MenuState>(MenuNotifier.new);
