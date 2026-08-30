import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/menu_model.dart';
import '../data/menu_repository.dart';
import 'menu_provider.dart';

/// S7 — Item editor with photo upload and option groups.
class ItemEditorScreen extends ConsumerStatefulWidget {
  const ItemEditorScreen({super.key, required this.uuid});

  final String uuid;

  @override
  ConsumerState<ItemEditorScreen> createState() => _ItemEditorScreenState();
}

class _ItemEditorScreenState extends ConsumerState<ItemEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _pickedImage;
  bool _isSaving = false;
  bool _isUploading = false;
  MenuItem? _item;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItem());
  }

  void _loadItem() {
    final menu = ref.read(menuProvider);
    final item = menu.items.where((i) => i.uuid == widget.uuid).firstOrNull;
    if (item != null) {
      _item = item;
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit item'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _item == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo upload area
                  _PhotoUploadArea(
                    imageUrl: _item!.imageUrl,
                    pickedFile: _pickedImage,
                    isUploading: _isUploading,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  // Option groups — collapsed
                  if (_item!.groups.isNotEmpty) ...[
                    Text(
                      'Option groups',
                      style: AppTextStyles.titleS.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    ..._item!.groups.map((g) => _OptionGroupTile(group: g)),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(menuRepositoryProvider);
      String? imageUrl = _item!.imageUrl;

      if (_pickedImage != null) {
        setState(() => _isUploading = true);
        imageUrl = await repo.uploadPhoto(widget.uuid, _pickedImage!);
        setState(() => _isUploading = false);
      }

      await repo.updateItem(widget.uuid, {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        if (imageUrl != null) 'image_url': imageUrl,
      });

      await ref.read(menuProvider.notifier).refresh();
      if (mounted) context.pop();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    }
  }
}

class _PhotoUploadArea extends StatelessWidget {
  const _PhotoUploadArea({
    required this.imageUrl,
    required this.pickedFile,
    required this.isUploading,
    required this.onTap,
  });

  final String? imageUrl;
  final File? pickedFile;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: isUploading
              ? const Center(child: CircularProgressIndicator())
              : pickedFile != null
                  ? Image.file(pickedFile!, fit: BoxFit.cover)
                  : imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _placeholder,
                        )
                      : _placeholder,
        ),
      ),
    );
  }

  Widget get _placeholder => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.add_photo_alternate_outlined,
          size: 48, color: AppColors.primary),
      const SizedBox(height: 8),
      Text(
        'Add photo',
        style: AppTextStyles.body.copyWith(color: AppColors.primary),
      ),
    ],
  );
}

class _OptionGroupTile extends StatelessWidget {
  const _OptionGroupTile({required this.group});
  final OptionGroup group;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExpansionTile(
      title: Text(group.title),
      children: group.options.map((opt) {
        return ListTile(
          dense: true,
          title: Text(opt.label, style: AppTextStyles.dense),
          trailing: opt.priceDeltaMinor > 0
              ? Text(
                  '+৳${(opt.priceDeltaMinor / 100).toStringAsFixed(0)}',
                  style: AppTextStyles.price.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                )
              : null,
        );
      }).toList(),
    );
  }
}
