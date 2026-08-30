import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.uuid,
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.createdAt,
    this.merchantReply,
  });

  final String uuid;
  final int rating;
  final String? comment;
  final String customerName;
  final DateTime createdAt;
  final String? merchantReply;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      uuid: json['uuid'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      customerName: json['customer_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      merchantReply: json['merchant_reply'] as String?,
    );
  }

  Review copyWith({
    String? merchantReply,
  }) {
    return Review(
      uuid: uuid,
      rating: rating,
      comment: comment,
      customerName: customerName,
      createdAt: createdAt,
      merchantReply: merchantReply ?? this.merchantReply,
    );
  }

  @override
  List<Object?> get props => [uuid, rating, comment, customerName, createdAt, merchantReply];
}
