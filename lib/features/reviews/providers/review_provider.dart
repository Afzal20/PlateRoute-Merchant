import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review.dart';

class ReviewState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;

  ReviewState({
    this.reviews = const [],
    this.isLoading = true,
    this.error,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReviewNotifier extends Notifier<ReviewState> {
  @override
  ReviewState build() {
    Future.microtask(_fetch);
    return ReviewState();
  }

  Future<void> _fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Mock API call for now
      await Future.delayed(const Duration(seconds: 1));
      final mockReviews = [
        Review(
          uuid: 'r1',
          rating: 5,
          comment: 'Great food, fast delivery!',
          customerName: 'John D.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Review(
          uuid: 'r2',
          rating: 3,
          comment: 'A bit salty today.',
          customerName: 'Sarah M.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      state = state.copyWith(reviews: mockReviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() => _fetch();

  Future<void> replyToReview(String uuid, String reply) async {
    // Optimistic update
    final updatedReviews = state.reviews.map((r) {
      if (r.uuid == uuid) {
        return r.copyWith(merchantReply: reply);
      }
      return r;
    }).toList();
    state = state.copyWith(reviews: updatedReviews);

    // TODO: implement actual API call for review reply
  }
}

final reviewProvider = NotifierProvider<ReviewNotifier, ReviewState>(ReviewNotifier.new);
