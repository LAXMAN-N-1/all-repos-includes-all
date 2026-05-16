import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../models/station_state.dart';
import '../../../core/utils/time_utils.dart';

/// Review card with inline reply composer
class RatingReviewCard extends StatefulWidget {
  final ReviewDto review;
  final Function(int reviewId, String replyText) onReply;

  const RatingReviewCard({super.key, required this.review, required this.onReply});

  @override
  State<RatingReviewCard> createState() => _RatingReviewCardState();
}

class _RatingReviewCardState extends State<RatingReviewCard> {
  bool _showReplyComposer = false;
  bool _isEditing = false;
  late final TextEditingController _replyC;

  @override
  void initState() {
    super.initState();
    _replyC = TextEditingController(text: widget.review.dealerReply ?? '');
  }

  @override
  void dispose() { _replyC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final hasReply = r.dealerReply != null && r.dealerReply!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: avatar, name, stars, date
        Row(children: [
          // Avatar
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(r.customerInitial, style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15,
            ))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(r.customerName, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
              )),
              if (r.isVerifiedRental) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.badgeCheck, size: 9, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('Verified', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            // Stars
            Row(children: [
              ...List.generate(5, (i) => Icon(
                LucideIcons.star, size: 12,
                color: i < r.rating ? AppColors.amber : AppColors.textMuted,
              )),
              const SizedBox(width: 6),
              Text(r.rating.toString(), style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
              )),
            ]),
          ])),
          // Station badge + date
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.pageBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(r.stationName, style: const TextStyle(
                fontSize: 9, color: AppColors.textTertiary, fontWeight: FontWeight.w500,
              )),
            ),
            const SizedBox(height: 4),
            Text(_formatDate(r.createdAt), style: const TextStyle(
              fontSize: 10, color: AppColors.textMuted,
            )),
          ]),
        ]),

        const SizedBox(height: 14),

        // Review text
        if (r.reviewText != null && r.reviewText!.isNotEmpty)
          Text(r.reviewText!, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.5,
          )),

        // Dealer reply (if exists)
        if (hasReply) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(LucideIcons.messageSquare, size: 12, color: AppColors.primary),
                const SizedBox(width: 6),
                const Text('Dealer Response', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5,
                )),
                const Spacer(),
                if (r.repliedAt != null)
                  Text(_formatDate(r.repliedAt!), style: const TextStyle(
                    fontSize: 9, color: AppColors.textMuted,
                  )),
              ]),
              const SizedBox(height: 8),
              Text(r.dealerReply!, style: const TextStyle(
                fontSize: 12, color: AppColors.textPrimary, height: 1.5,
              )),
            ]),
          ),
        ],

        const SizedBox(height: 12),

        // Reply/Edit button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: Icon(hasReply ? LucideIcons.edit3 : LucideIcons.reply, size: 13),
            label: Text(hasReply ? 'Edit Reply' : 'Reply', style: const TextStyle(fontSize: 12)),
            onPressed: () => setState(() {
              _showReplyComposer = !_showReplyComposer;
              _isEditing = hasReply;
              if (hasReply) _replyC.text = r.dealerReply!;
            }),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),

        // Reply composer
        if (_showReplyComposer) ...[
          const Divider(height: 20),
          TextField(
            controller: _replyC,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Write your response to this customer...',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              filled: true, fillColor: AppColors.pageBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_replyC.text.length} characters',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Row(children: [
              TextButton(
                onPressed: () => setState(() => _showReplyComposer = false),
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_replyC.text.trim().isNotEmpty) {
                    widget.onReply(r.id, _replyC.text.trim());
                    setState(() => _showReplyComposer = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(_isEditing ? 'Update Reply' : 'Send Reply',
                  style: const TextStyle(fontSize: 12)),
              ),
            ]),
          ]),
        ],
      ]),
    );
  }

  String _formatDate(String iso) => TimeUtils.timeAgo(iso);
}
