import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/export_helper.dart';
import '../providers/station_detail_provider.dart';
import '../models/station_state.dart';
import '../widgets/rating_review_card.dart';

class RatingsScreen extends ConsumerStatefulWidget {
  final String? stationId;
  const RatingsScreen({super.key, this.stationId});
  @override
  ConsumerState<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends ConsumerState<RatingsScreen> {
  int? _filterRating;
  String _replyFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final sid =
        widget.stationId != null ? int.tryParse(widget.stationId!) : null;
    final reviewsAsync = ref.watch(stationReviewsProvider(sid));
    final scope = sid != null ? 'Station #$sid' : 'All Stations';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Back
        GestureDetector(
          onTap: () => context.go('/stations'),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Back to Stations',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 18),

        // Header
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child:
                const Icon(LucideIcons.star, size: 20, color: AppColors.purple),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Ratings & Reviews',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Text('Customer feedback • $scope',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ])),
          OutlinedButton.icon(
            icon: const Icon(LucideIcons.download, size: 14),
            label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
            onPressed: () => _handleExport(sid),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border)),
          ),
        ]),
        const SizedBox(height: 24),

        reviewsAsync.when(
          data: (reviews) => _buildContent(reviews),
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(color: AppColors.purple))),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.red))),
        ),
      ]),
    );
  }

  Widget _buildContent(List<ReviewDto> allReviews) {
    // Apply filters
    var filtered = allReviews.toList();
    if (_filterRating != null) {
      filtered = filtered.where((r) => r.rating == _filterRating).toList();
    }
    if (_replyFilter == 'replied') {
      filtered = filtered
          .where((r) => r.dealerReply != null && r.dealerReply!.isNotEmpty)
          .toList();
    } else if (_replyFilter == 'not_replied') {
      filtered = filtered
          .where((r) => r.dealerReply == null || r.dealerReply!.isEmpty)
          .toList();
    }

    // Stats
    final avgRating = allReviews.isEmpty
        ? 0.0
        : allReviews.fold(0, (sum, r) => sum + r.rating) / allReviews.length;
    final repliedCount = allReviews
        .where((r) => r.dealerReply != null && r.dealerReply!.isNotEmpty)
        .length;
    final replyRate = allReviews.isEmpty
        ? 0
        : (repliedCount / allReviews.length * 100).round();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary card
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Main rating
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Column(children: [
              Text(avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                            LucideIcons.star,
                            size: 18,
                            color: i < avgRating.round()
                                ? AppColors.amber
                                : AppColors.textMuted,
                          ))),
              const SizedBox(height: 4),
              Text('${allReviews.length} reviews',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary)),
            ]),
            const SizedBox(width: 30),
            // Distribution bars
            Expanded(
                child: Column(
                    children: List.generate(5, (i) {
              final stars = 5 - i;
              final count = allReviews.where((r) => r.rating == stars).length;
              final fraction =
                  allReviews.isEmpty ? 0.0 : count / allReviews.length;
              final color = stars >= 4
                  ? AppColors.primary
                  : stars == 3
                      ? AppColors.amber
                      : AppColors.red;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(
                      width: 20,
                      child: Text('$stars',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textTertiary))),
                  const Icon(LucideIcons.star,
                      size: 10, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                                value: fraction,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation(color)),
                          ))),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 30,
                      child: Text('$count',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textTertiary),
                          textAlign: TextAlign.right)),
                ]),
              );
            }))),
          ]),
        )),
        const SizedBox(width: 14),
        // Reply stats
        Column(children: [
          _replyStatTile('Reply Rate', '$replyRate%', AppColors.primary),
          const SizedBox(height: 10),
          _replyStatTile(
              'Replied', '$repliedCount/${allReviews.length}', AppColors.cyan),
        ]),
      ]),
      const SizedBox(height: 20),

      // Filter bar
      Row(children: [
        // Star filters
        ...[null, 5, 4, 3, 2, 1].map((rating) {
          final sel = _filterRating == rating;
          final label = rating == null ? 'All' : '$rating ★';
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _filterRating = rating),
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.amber.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel
                              ? AppColors.amber.withValues(alpha: 0.4)
                              : AppColors.border),
                    ),
                    child: Text(label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          color:
                              sel ? AppColors.amber : AppColors.textSecondary,
                        )),
                  )),
            ),
          );
        }),
        const SizedBox(width: 12),
        Container(width: 1, height: 24, color: AppColors.border),
        const SizedBox(width: 12),
        // Reply filters
        ...['all', 'replied', 'not_replied'].map((f) {
          final sel = _replyFilter == f;
          final label = f == 'all'
              ? 'All'
              : f == 'replied'
                  ? 'Replied'
                  : 'Not Replied';
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _replyFilter = f),
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.cyan.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel
                              ? AppColors.cyan.withValues(alpha: 0.4)
                              : AppColors.border),
                    ),
                    child: Text(label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel ? AppColors.cyan : AppColors.textSecondary,
                        )),
                  )),
            ),
          );
        }),
      ]),
      const SizedBox(height: 20),

      // Reviews
      if (filtered.isEmpty)
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: const Center(
              child: Text('No reviews match your filters',
                  style: TextStyle(color: AppColors.textTertiary))),
        )
      else
        ...filtered.map((r) => RatingReviewCard(
              review: r,
              onReply: (id, text) async {
                try {
                  await ref.read(stationReviewActionsProvider).replyToReview(
                        reviewId: id,
                        replyText: text,
                        stationId: widget.stationId != null
                            ? int.tryParse(widget.stationId!)
                            : null,
                      );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Reply saved!'),
                        backgroundColor: AppColors.primary),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to save reply: $e'),
                        backgroundColor: AppColors.red),
                  );
                }
              },
            )),
    ]);
  }

  Widget _replyStatTile(String label, String value, Color color) => Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ]),
      );

  Future<void> _handleExport(int? sid) async {
    if (sid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a station to export ratings')),
      );
      return;
    }
    final reviews = ref.read(stationReviewsProvider(sid)).valueOrNull;
    if (reviews == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviews are still loading')),
      );
      return;
    }
    final fileName =
        'station_${sid}_reviews_${DateTime.now().millisecondsSinceEpoch}';
    ExportHelper.exportReviewsToCsv(reviews, fileName);
  }
}
