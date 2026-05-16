import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';

enum QuickSelectPill {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last3Months,
  custom,
}

class SalesDateRangePicker extends StatefulWidget {
  final DateTime initialFrom;
  final DateTime initialTo;
  final Function(DateTime from, DateTime to, QuickSelectPill pill) onDateRangeChanged;

  const SalesDateRangePicker({
    super.key,
    required this.initialFrom,
    required this.initialTo,
    required this.onDateRangeChanged,
  });

  @override
  State<SalesDateRangePicker> createState() => _SalesDateRangePickerState();
}

class _SalesDateRangePickerState extends State<SalesDateRangePicker> {
  late DateTime _fromDate;
  late DateTime _toDate;
  QuickSelectPill _selectedPill = QuickSelectPill.thisMonth;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFrom;
    _toDate = widget.initialTo;
  }

  void _onPillSelected(QuickSelectPill pill) {
    if (pill == QuickSelectPill.custom) {
      _selectDateRange();
      return;
    }

    final now = DateTime.now();
    DateTime from = now;
    DateTime to = now;

    switch (pill) {
      case QuickSelectPill.today:
        from = DateTime(now.year, now.month, now.day);
        to = from.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        break;
      case QuickSelectPill.yesterday:
        from = DateTime(now.year, now.month, now.day - 1);
        to = from.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        break;
      case QuickSelectPill.thisWeek:
        from = now.subtract(Duration(days: now.weekday - 1));
        from = DateTime(from.year, from.month, from.day);
        to = now;
        break;
      case QuickSelectPill.lastWeek:
        final lastWeek = now.subtract(const Duration(days: 7));
        from = lastWeek.subtract(Duration(days: lastWeek.weekday - 1));
        from = DateTime(from.year, from.month, from.day);
        to = from.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
        break;
      case QuickSelectPill.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = now;
        break;
      case QuickSelectPill.lastMonth:
        from = DateTime(now.year, now.month - 1, 1);
        to = DateTime(now.year, now.month, 1).subtract(const Duration(milliseconds: 1));
        break;
      case QuickSelectPill.last3Months:
        from = DateTime(now.year, now.month - 2, 1);
        to = now;
        break;
      default:
        break;
    }

    setState(() {
      _selectedPill = pill;
      _fromDate = from;
      _toDate = to;
    });

    widget.onDateRangeChanged(_fromDate, _toDate, _selectedPill);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBg,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
        _selectedPill = QuickSelectPill.custom;
      });
      widget.onDateRangeChanged(_fromDate, _toDate, _selectedPill);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick select pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: QuickSelectPill.values.map((pill) {
              final label = _getPillLabel(pill);
              final isSelected = _selectedPill == pill;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _onPillSelected(pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Date inputs
        Row(
          children: [
            _DateInput(
              label: 'From',
              date: _fromDate,
              onTap: _selectDateRange,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(
                LucideIcons.calendar,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
            _DateInput(
              label: 'To',
              date: _toDate,
              onTap: _selectDateRange,
            ),
          ],
        ),
      ],
    );
  }

  String _getPillLabel(QuickSelectPill pill) {
    switch (pill) {
      case QuickSelectPill.today: return 'Today';
      case QuickSelectPill.yesterday: return 'Yesterday';
      case QuickSelectPill.thisWeek: return 'This Week';
      case QuickSelectPill.lastWeek: return 'Last Week';
      case QuickSelectPill.thisMonth: return 'This Month';
      case QuickSelectPill.lastMonth: return 'Last Month';
      case QuickSelectPill.last3Months: return 'Last 3 Months';
      case QuickSelectPill.custom: return 'Custom';
    }
  }
}

class _DateInput extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateInput({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
