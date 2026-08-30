import 'package:equatable/equatable.dart';

class Option extends Equatable {
  const Option({
    required this.id,
    required this.label,
    this.priceDeltaMinor = 0,
    this.isDefault = false,
    this.available = true,
  });

  final int id;
  final String label;
  final int priceDeltaMinor;
  final bool isDefault;
  final bool available;

  factory Option.fromJson(Map<String, dynamic> j) => Option(
    id: j['id'] as int,
    label: j['label'] as String,
    priceDeltaMinor: (j['price_delta_minor'] as num?)?.toInt() ?? 0,
    isDefault: j['is_default'] as bool? ?? false,
    available: j['available'] as bool? ?? true,
  );

  @override
  List<Object?> get props => [id];
}

class OptionGroup extends Equatable {
  const OptionGroup({
    required this.id,
    required this.title,
    this.minSelect = 0,
    this.maxSelect = 1,
    this.options = const [],
  });

  final int id;
  final String title;
  final int minSelect;
  final int maxSelect;
  final List<Option> options;

  factory OptionGroup.fromJson(Map<String, dynamic> j) => OptionGroup(
    id: j['id'] as int,
    title: j['title'] as String,
    minSelect: (j['min_select'] as num?)?.toInt() ?? 0,
    maxSelect: (j['max_select'] as num?)?.toInt() ?? 1,
    options: (j['options'] as List<dynamic>?)
            ?.map((o) => Option.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [],
  );

  @override
  List<Object?> get props => [id];
}

class MenuItem extends Equatable {
  const MenuItem({
    required this.uuid,
    required this.category,
    required this.categoryName,
    required this.branch,
    required this.name,
    required this.basePriceMinor,
    this.description = '',
    this.imageUrl,
    this.currency = 'BDT',
    this.available = true,
    this.sortKey = 0,
    this.groups = const [],
  });

  final String uuid;
  final String category;
  final String categoryName;
  final String branch;
  final String name;
  final String description;
  final String? imageUrl;
  final int basePriceMinor;
  final String currency;
  final bool available;
  final int sortKey;
  final List<OptionGroup> groups;

  String get formattedPrice => '৳${(basePriceMinor / 100).toStringAsFixed(0)}';

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
    uuid: j['uuid'] as String,
    category: j['category'] as String? ?? '',
    categoryName: j['category_name'] as String? ?? '',
    branch: j['branch'] as String? ?? '',
    name: j['name'] as String,
    description: j['description'] as String? ?? '',
    imageUrl: j['image_url'] as String?,
    basePriceMinor: (j['base_price_minor'] as num?)?.toInt() ?? 0,
    currency: j['currency'] as String? ?? 'BDT',
    available: j['available'] as bool? ?? true,
    sortKey: (j['sort_key'] as num?)?.toInt() ?? 0,
    groups: (j['groups'] as List<dynamic>?)
            ?.map((g) => OptionGroup.fromJson(g as Map<String, dynamic>))
            .toList() ??
        [],
  );

  MenuItem copyWith({
    bool? available,
    int? basePriceMinor,
    String? imageUrl,
  }) {
    return MenuItem(
      uuid: uuid,
      category: category,
      categoryName: categoryName,
      branch: branch,
      name: name,
      description: description,
      imageUrl: imageUrl ?? this.imageUrl,
      basePriceMinor: basePriceMinor ?? this.basePriceMinor,
      currency: currency,
      available: available ?? this.available,
      sortKey: sortKey,
      groups: groups,
    );
  }

  @override
  List<Object?> get props => [uuid, available, basePriceMinor];
}

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.uuid,
    required this.name,
    this.position = 0,
    this.items = const [],
  });

  final String uuid;
  final String name;
  final int position;
  final List<MenuItem> items;

  factory MenuCategory.fromJson(Map<String, dynamic> j) => MenuCategory(
    uuid: j['uuid'] as String,
    name: j['name'] as String,
    position: (j['position'] as num?)?.toInt() ?? 0,
  );

  MenuCategory withItems(List<MenuItem> items) => MenuCategory(
    uuid: uuid,
    name: name,
    position: position,
    items: items,
  );

  @override
  List<Object?> get props => [uuid];
}
