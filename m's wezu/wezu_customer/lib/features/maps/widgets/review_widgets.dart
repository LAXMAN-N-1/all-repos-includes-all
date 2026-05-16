import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/review.dart';

/// Interactive star rating widget for review submission
class StarRatingInput extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () => onRatingChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              rating >= starValue
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: rating >= starValue ? Colors.amber : Colors.grey[400],
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

/// Read-only star display for reviews
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;

  const StarRatingDisplay({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, color: Colors.amber, size: size);
      }),
    );
  }
}

/// Overall rating summary card (large number + stars + count)
class RatingSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final bool isDark;

  const RatingSummaryCard({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Large rating number
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              StarRatingDisplay(rating: averageRating, size: 18),
              const SizedBox(height: 4),
              Text('($totalReviews reviews)',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 24),
          // Rating distribution bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final percentage = totalReviews > 0
                    ? (star == 5
                        ? 0.6
                        : star == 4
                            ? 0.25
                            : star == 3
                                ? 0.1
                                : 0.03)
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 10, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor:
                                isDark ? Colors.white10 : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.amber),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual review card widget
class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isDark;

  const ReviewCard({super.key, required this.review, required this.isDark});

  String _maskName(String name) {
    if (name.length <= 3) return '$name***';
    return '${name.substring(0, 3)}***';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.outfit(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_maskName(review.userName),
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      if (review.isVerifiedRental) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('Verified',
                              style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  Text(_timeAgo(review.createdAt),
                      style:
                          GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              StarRatingDisplay(rating: review.rating, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5),
          ),
          if (review.helpfulCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.thumbsUp, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text('${review.helpfulCount} found helpful',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
          if (review.responseFromStation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.messageCircle,
                      size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Station Response',
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue)),
                        const SizedBox(height: 4),
                        Text(review.responseFromStation!,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
