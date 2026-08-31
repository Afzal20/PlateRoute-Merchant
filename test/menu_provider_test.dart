import 'package:flutter_test/flutter_test.dart';
import 'package:merchant/features/menu/data/menu_model.dart';
import 'package:merchant/features/menu/presentation/menu_provider.dart';

void main() {
  group('MenuState logic', () {
    test('toggleAvailability optimistic update', () {
      final item = MenuItem(
        uuid: 'item-1',
        name: 'Burger',
        description: '',
        category: 'cat-1',
        categoryName: 'Category 1',
        branch: 'branch-1',
        basePriceMinor: 500,
        available: true,
        sortKey: 1,
      );

      var state = MenuState(items: [item], syncingItems: {});
      
      // Optimistically flip
      final updated = state.items.map((i) {
        if (i.uuid == 'item-1') return i.copyWith(available: !i.available);
        return i;
      }).toList();
      
      state = state.copyWith(items: updated, syncingItems: {'item-1'});

      expect(state.items.first.available, false);
      expect(state.syncingItems.contains('item-1'), true);
    });
    
    test('updatePrice optimistic update', () {
      final item = MenuItem(
        uuid: 'item-1',
        name: 'Burger',
        description: '',
        category: 'cat-1',
        categoryName: 'Category 1',
        branch: 'branch-1',
        basePriceMinor: 500,
        available: true,
        sortKey: 1,
      );

      var state = MenuState(items: [item]);
      
      // Optimistically update
      final updated = state.items.map((i) {
        if (i.uuid == 'item-1') return i.copyWith(basePriceMinor: 600);
        return i;
      }).toList();
      
      state = state.copyWith(items: updated);

      expect(state.items.first.basePriceMinor, 600);
    });
  });
}
