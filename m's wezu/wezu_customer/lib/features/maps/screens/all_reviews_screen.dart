import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/review_providers.dart';
import '../widgets/review_widgets.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  final int stationId;
  final String stationName;

  const AllReviewsScreen(
      {super.key, required this.stationId, required this.stationName});

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  @override
  void initState() {
    super.initState();
    // Load reviews for this station
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadReviews(widget.stationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviewState = ref.watch(reviewProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reviews',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            Text(widget.stationName,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: reviewState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviewState.reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.messageSquare,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No reviews yet',
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Be the first to review this station!',
                          style: GoogleFonts.inter(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Rating Summary
                    RatingSummaryCard(
                      averageRating: reviewState.averageRating,
                      totalReviews: reviewState.totalCount,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'All Reviews (${reviewState.totalCount})',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    // Review list
                    ...reviewState.reviews
                        .map((r) => ReviewCard(review: r, isDark: isDark)),
                  ],
                ),
    );
  }
}
