import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rental_providers.dart';

class IssueReportSheet extends ConsumerStatefulWidget {
  final int rentalId;
  final Function(String ticketId) onReported;

  const IssueReportSheet({
    super.key,
    required this.rentalId,
    required this.onReported,
  });

  @override
  ConsumerState<IssueReportSheet> createState() => _IssueReportSheetState();
}

class _IssueReportSheetState extends ConsumerState<IssueReportSheet> {
  String? _selectedCategory;
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  static const List<String> _categories = [
    'Battery Draining Too Fast',
    'Connector Broken',
    'Wrong Battery Dispensed',
    'Battery Not Charging',
    'Other',
  ];

  static const Map<String, IconData> _categoryIcons = {
    'Battery Draining Too Fast': LucideIcons.batteryLow,
    'Connector Broken': LucideIcons.unplug,
    'Wrong Battery Dispensed': LucideIcons.alertTriangle,
    'Battery Not Charging': LucideIcons.batteryCharging,
    'Other': LucideIcons.helpCircle,
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "What's the issue with your battery?",
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a category and describe the problem.',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcons[cat] ?? LucideIcons.helpCircle,
                          size: 16,
                          color: isSelected ? AppTheme.primaryBlue : Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat,
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Describe the issue (optional but helpful)',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Battery went from 80% to 20% in 30 minutes...',
                hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedCategory == null || _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.redAccent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'SUBMIT REPORT',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(rentalRepositoryProvider);
      final desc = _descriptionController.text.trim();
      final result = await repo.reportIssue(
        widget.rentalId,
        _selectedCategory!,
        desc.isNotEmpty ? desc : null,
      );
      if (result['success'] == true && mounted) {
        widget.onReported(result['ticket_id'] ?? 'TKT-0000');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report issue: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
