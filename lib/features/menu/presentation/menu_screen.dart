import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/menu_model.dart';
import 'menu_provider.dart';

/// S5 — Menu manager list with categories, items, AvailabilitySwitch,
/// store-health card on top.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add item',
            onPressed: () => context.push('/menu/item/new'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(menuProvider.notifier).refresh(),
          ),
        ],
      ),
      body: menu.isLoading
          ? const Center(child: CircularProgressIndicator())
          : menu.error != null && menu.items.isEmpty
              ? _ErrorView(
                  message: menu.error!,
                  onRetry: () => ref.read(menuProvider.notifier).refresh(),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(menuProvider.notifier).refresh(),
                  child: CustomScrollView(
                    slivers: [
                      // Store health card at top
                      const SliverToBoxAdapter(child: _StoreHealthCard()),
                      // Categories + items
                      ...menu.categoriesWithItems.map(
                        (cat) => _CategorySection(
                          category: cat,
                          syncingItems: menu.syncingItems,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
    );
  }
}

class _StoreHealthCard extends StatelessWidget {
  const _StoreHealthCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(AppSizes.spacingM),
      elevation: 0,
      color: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Row(
          children: [
            const Icon(Icons.health_and_safety, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store health',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '2 items missing photos',
                    style: AppTextStyles.dense.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {}, // one fix per visit
              child: Text(
                'Fix now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.syncingItems,
  });

  final MenuCategory category;
  final Set<String> syncingItems;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingL,
              AppSizes.spacingM,
              AppSizes.spacingXS,
            ),
            child: Text(
              category.name,
              style: AppTextStyles.titleS.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _MenuItemRow(
              item: category.items[i],
              isSyncing: syncingItems.contains(category.items[i].uuid),
            ),
            childCount: category.items.length,
          ),
        ),
      ],
    );
  }
}

class _MenuItemRow extends ConsumerWidget {
  const _MenuItemRow({required this.item, required this.isSyncing});

  final MenuItem item;
  final bool isSyncing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: () => context.push('/menu/item/${item.uuid}'),
      child: Container(
        height: AppSizes.listRow,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
        child: Row(
          children: [
            // Thumbnail 56dp
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      width: AppSizes.thumbnailSize,
                      height: AppSizes.thumbnailSize,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _PlaceholderThumbnail(),
                    )
                  : _PlaceholderThumbnail(),
            ),
            const SizedBox(width: AppSizes.spacingM),
            // Name + price
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () => context.push('/menu/price/${item.uuid}'),
                    child: Row(
                      children: [
                        Text(
                          item.formattedPrice,
                          style: AppTextStyles.price.copyWith(color: textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit, size: 12, color: AppColors.primary.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Sync chip
            if (isSyncing)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Syncing…',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey),
                ),
              ),
            // AvailabilitySwitch
            _AvailabilitySwitch(
              uuid: item.uuid,
              available: item.available,
            ),
          ],
        ),
      ),
    );
  }
}

/// 84x40 custom switch for item availability — unmistakable under motion.
class _AvailabilitySwitch extends ConsumerWidget {
  const _AvailabilitySwitch({
    required this.uuid,
    required this.available,
  });

  final String uuid;
  final bool available;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(menuProvider.notifier).toggleAvailability(uuid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: AppSizes.availabilityTrackWidth,
        height: AppSizes.availabilityThumbSize,
        decoration: BoxDecoration(
          color: available
              ? AppColors.actionAcceptDark.withOpacity(0.15)
              : Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: available ? AppColors.actionAcceptDark : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // OFF label at left edge
            Positioned(
              left: 8,
              child: Text(
                'OFF',
                style: AppTextStyles.caption.copyWith(
                  color: available ? Colors.transparent : Colors.grey,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            // ON label at right edge
            Positioned(
              right: 8,
              child: Text(
                'ON',
                style: AppTextStyles.caption.copyWith(
                  color: available ? AppColors.actionAcceptDark : Colors.transparent,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            // Thumb
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              alignment:
                  available ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: available
                      ? AppColors.actionAcceptDark
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  available ? Icons.check : Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderThumbnail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.thumbnailSize,
      height: AppSizes.thumbnailSize,
      color: Colors.grey.withOpacity(0.2),
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 24),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
