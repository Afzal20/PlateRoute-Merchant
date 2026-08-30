import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/idempotent_submit_button.dart';

class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.createdAt,
    this.replyText,
  });

  final int id;
  final int rating;
  final String comment;
  final String customerName;
  final DateTime createdAt;
  final String? replyText;
}

/// S10 — Reviews list with reply composer.
class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  // Mock reviews until API wired
  final _reviews = [
    Review(
      id: 1,
      rating: 5,
      comment: 'Amazing food! Came really hot and on time.',
      customerName: 'Rafiq',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 2,
      rating: 3,
      comment: 'Good taste but a bit delayed.',
      customerName: 'Nasrin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        itemCount: _reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacingS),
        itemBuilder: (ctx, i) => _ReviewCard(
          review: _reviews[i],
          onReply: () => _showReplySheet(ctx, _reviews[i]),
        ),
      ),
    );
  }

  void _showReplySheet(BuildContext context, Review review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewReplyComposer(
        review: review,
        onSend: (text) async {
          // POST /reviews/{id}/reply/
          try {
            final apiClientAsync = ref.read(apiClientProvider);
            final dio = apiClientAsync.when(
              data: (c) => c.dio,
              loading: () => Dio(),
              error: (_, __) => Dio(),
            );
            await dio.post('/reviews/${review.id}/reply/', data: {'text': text});
          } catch (_) {
            // Show error
          }
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onReply});
  final Review review;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Stars
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppColors.queuePulse,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.customerName,
                  style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                ),
                const Spacer(),
                if (review.replyText == null)
                  TextButton(
                    onPressed: onReply,
                    child: Text(
                      'Reply',
                      style: AppTextStyles.dense.copyWith(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              review.comment,
              style: AppTextStyles.body.copyWith(color: textSecondary),
            ),
            if (review.replyText != null) ...[
              const SizedBox(height: AppSizes.spacingS),
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.reply, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        review.replyText!,
                        style: AppTextStyles.dense.copyWith(color: textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewReplyComposer extends StatefulWidget {
  const _ReviewReplyComposer({required this.review, required this.onSend});
  final Review review;
  final Future<void> Function(String text) onSend;

  @override
  State<_ReviewReplyComposer> createState() => _ReviewReplyComposerState();
}

class _ReviewReplyComposerState extends State<_ReviewReplyComposer> {
  final _ctrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.spacingL,
        left: AppSizes.spacingM,
        right: AppSizes.spacingM,
        top: AppSizes.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            'Reply to customer',
            style: AppTextStyles.titleS.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Write a professional, helpful reply…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          SizedBox(
            height: AppSizes.touchPrimary,
            child: IdempotentSubmitButton(
              onPressed: () async {
                if (_ctrl.text.isEmpty) return;
                await widget.onSend(_ctrl.text.trim());
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Text(
                      'Send reply',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
