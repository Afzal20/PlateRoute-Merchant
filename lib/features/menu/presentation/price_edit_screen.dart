import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/menu_model.dart';
import 'menu_provider.dart';

/// S8 — Numeric price sheet with big keys, old vs new confirm row,
/// 1.5s autosave debounce.
class PriceEditScreen extends ConsumerStatefulWidget {
  const PriceEditScreen({super.key, required this.uuid});

  final String uuid;

  @override
  ConsumerState<PriceEditScreen> createState() => _PriceEditScreenState();
}

class _PriceEditScreenState extends ConsumerState<PriceEditScreen> {
  String _input = '';
  MenuItem? _item;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menu = ref.read(menuProvider);
      final item = menu.items.where((i) => i.uuid == widget.uuid).firstOrNull;
      if (item != null) setState(() => _item = item);
    });
  }

  int get _newPriceMinor {
    final parsed = int.tryParse(_input) ?? 0;
    return parsed * 100; // whole taka -> minor units
  }

  void _onKey(String key) {
    setState(() {
      if (key == '<') {
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
      } else if (_input.length < 6) {
        _input = _input + key;
      }
    });
  }

  void _confirm() {
    if (_newPriceMinor <= 0) return;
    ref.read(menuProvider.notifier).updatePrice(widget.uuid, _newPriceMinor);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(_item?.name ?? 'Update price'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.spacingL),
            // Display area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spacingL),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.canvasLight,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: Text(
                _input.isEmpty ? '0' : '৳$_input',
                style: AppTextStyles.titleL.copyWith(
                  fontSize: 48,
                  color: _input.isEmpty ? Colors.grey : textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            // Old vs new confirm row
            if (_item != null && _input.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                decoration: BoxDecoration(
                  color: AppColors.actionAcceptDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  border: Border.all(
                    color: AppColors.actionAcceptDark.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Current',
                            style: AppTextStyles.caption.copyWith(
                                color: textSecondary)),
                        Text(
                          _item!.formattedPrice,
                          style: AppTextStyles.price.copyWith(
                            color: textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, color: AppColors.actionAcceptDark),
                    Column(
                      children: [
                        Text('New price',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.actionAcceptDark)),
                        Text(
                          '৳$_input',
                          style: AppTextStyles.price.copyWith(
                            color: AppColors.actionAcceptDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const Spacer(),
            // Big numeric keypad
            _NumericPad(onKey: _onKey),
            const SizedBox(height: AppSizes.spacingM),
            // Confirm button
            SizedBox(
              height: AppSizes.touchPrimary,
              width: double.infinity,
              child: FilledButton(
                onPressed: _input.isEmpty || _newPriceMinor <= 0 ? null : _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.actionAcceptDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
          ],
        ),
      ),
    );
  }
}

class _NumericPad extends StatelessWidget {
  const _NumericPad({required this.onKey});

  final void Function(String key) onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '<'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _keys.map((row) {
        return Row(
          children: row.map((key) {
            if (key.isEmpty) return Expanded(child: const SizedBox());
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: 64,
                  child: FilledButton(
                    onPressed: () => onKey(key),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          key == '<' ? Colors.grey.withOpacity(0.2) : null,
                      foregroundColor:
                          key == '<' ? AppColors.lateAlarm : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: key == '<'
                        ? const Icon(Icons.backspace_outlined, size: 22)
                        : Text(
                            key,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
