import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';

class StationsToolbar extends StatelessWidget {
  final String searchQuery;
  final String statusFilter;
  final Function(String) onSearchChanged;
  final Function(String) onStatusFilterChanged;
  final VoidCallback onAddStation;

  const StationsToolbar({
    super.key,
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onAddStation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 3,
        child: TextField(
          onChanged: onSearchChanged,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search stations by name, city, or ID...',
            prefixIcon: const Icon(LucideIcons.search, color: AppColors.textTertiary, size: 16),
            filled: true, fillColor: AppColors.pageBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 16),
      // Status filter pills
      ...['All', 'OPERATIONAL', 'MAINTENANCE', 'OFFLINE'].map((status) {
        final isSelected = statusFilter == status;
        final label = status == 'All' ? 'All' : status[0] + status.substring(1).toLowerCase();
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onStatusFilterChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
      const Spacer(),
      ElevatedButton.icon(
        icon: const Icon(LucideIcons.plus, size: 16),
        label: const Text('New Station', style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: onAddStation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ]);
  }
}
