import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rental_providers.dart';

class ExtendRentalSheet extends ConsumerStatefulWidget {
  final int rentalId;
  final Function(DateTime newEndTime, double amountCharged, int hours) onExtended;

  const ExtendRentalSheet({
    super.key,
    required this.rentalId,
    required this.onExtended,
  });

  @override
  ConsumerState<ExtendRentalSheet> createState() => _ExtendRentalSheetState();
}

class _ExtendRentalSheetState extends ConsumerState<ExtendRentalSheet> {
  int? _selectedHours;
  bool _isLoading = false;

  static const List<Map<String, dynamic>> _options = [
    {'label': '+2 hours', 'hours': 2, 'cost': 15.00},
    {'label': '+6 hours', 'hours': 6, 'cost': 45.00},
    {'label': '+12 hours', 'hours': 12, 'cost': 85.00},
    {'label': '+1 day', 'hours': 24, 'cost': 149.00},
  ];

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
              const Icon(LucideIcons.clock, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Extend Your Rental',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select how long you want to extend your rental period.',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ..._options.map((option) {
            final isSelected = _selectedHours == option['hours'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedHours = option['hours']),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white38, width: 2),
                          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option['label'],
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '₹${(option['cost'] as double).toInt()}',
                        style: GoogleFonts.outfit(
                          color: AppTheme.accentGreen,
                          fontSize: 18, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedHours == null || _isLoading ? null : _confirmExtension,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      'CONFIRM EXTENSION',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmExtension() {
    final selected = _options.firstWhere((o) => o['hours'] == _selectedHours);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Extension', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Extend by ${selected['label']} for ₹${(selected['cost'] as double).toInt()}?\n\nThis will be charged to your wallet.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeExtend();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirm', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeExtend() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(rentalRepositoryProvider);
      final result = await repo.extendRental(widget.rentalId, _selectedHours!);
      if (result['success'] == true && mounted) {
        final newEndTime = DateTime.parse(result['new_end_time']).toLocal();
        final amount = (result['amount_charged'] as num).toDouble();
        widget.onExtended(newEndTime, amount, _selectedHours!);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extend rental: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
