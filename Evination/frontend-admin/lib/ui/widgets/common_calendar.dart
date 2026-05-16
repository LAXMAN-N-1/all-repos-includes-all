import 'package:flutter/material.dart';

class CommonCalendar extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime firstDate;
  final DateTime lastDate;

  const CommonCalendar({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(8),
      child: CalendarDatePicker(
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        onDateChanged: onDateSelected,
      ),
    );
  }
}
