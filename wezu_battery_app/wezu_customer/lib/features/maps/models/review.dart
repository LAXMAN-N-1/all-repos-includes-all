class Review {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool isVerifiedRental;
  final int helpfulCount;
  final String? responseFromStation;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.isVerifiedRental = false,
    this.helpfulCount = 0,
    this.responseFromStation,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map ? user : const {};
    return Review(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      userName: userMap['full_name']?.toString() ?? 'Anonymous',
      userAvatar: userMap['avatar_url']?.toString(),
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isVerifiedRental: json['is_verified_rental'] ?? false,
      helpfulCount: json['helpful_count'] ?? 0,
      responseFromStation: json['response_from_station']?.toString(),
    );
  }
}
