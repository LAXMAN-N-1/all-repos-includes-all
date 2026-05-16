import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/review_providers.dart';
import 'review_widgets.dart';

class WriteReviewBottomSheet extends ConsumerStatefulWidget {
  final int stationId;
  final String stationName;

  const WriteReviewBottomSheet({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  ConsumerState<WriteReviewBottomSheet> createState() =>
      _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState
    extends ConsumerState<WriteReviewBottomSheet> {
  double _rating = 0;
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final charCount = _textController.text.length;
    final canSubmit = _rating > 0 && !_isSubmitting;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),

            // Title
            Text(
              'Rate ${widget.stationName}',
              style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('How was your experience?',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            // Interactive Stars
            StarRatingInput(
              rating: _rating,
              onRatingChanged: (val) => setState(() => _rating = val),
              size: 44,
            ),
            const SizedBox(height: 8),
            Text(
              _ratingLabel(_rating),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _rating > 0 ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Text input
            TextField(
              controller: _textController,
              maxLength: 300,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(
                  fontSize: 14, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Describe your experience... (optional)',
                hintStyle: GoogleFonts.inter(color: Colors.grey),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[50],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                ),
                counterText: '$charCount/300',
                counterStyle: GoogleFonts.inter(
                    fontSize: 11,
                    color: charCount > 280 ? Colors.red : Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSubmit ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: canSubmit ? 4 : 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Submit Review',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(double rating) {
    if (rating >= 5) return 'Outstanding!';
    if (rating >= 4) return 'Great!';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    if (rating >= 1) return 'Poor';
    return 'Tap a star to rate';
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    await ref.read(reviewProvider.notifier).submitReview(
          widget.stationId,
          _rating,
          _textController.text.trim(),
        );
    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your review!',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
