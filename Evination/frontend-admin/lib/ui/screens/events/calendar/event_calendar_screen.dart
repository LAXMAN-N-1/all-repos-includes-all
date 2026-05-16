import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../theme/app_theme.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Mock Data
    _events = {
      DateTime.now(): ['Wedding: Sharma Family', 'Corporate Meeting: TechCorp'],
      DateTime.now().add(const Duration(days: 2)): ['Birthday: Rahul'],
      DateTime.now().add(const Duration(days: 5)): ['Conference: AI Summit'],
    };
  }

  List<String> _getEventsForDay(DateTime day) {
    // Basic day matching (ignoring time)
    final events = <String>[];
    _events.forEach((key, value) {
       if (isSameDay(key, day)) {
         events.addAll(value);
       }
    });
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(bottom: 24),
              child: const Text('Event Calendar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar Widget
                  Expanded(
                    flex: 2,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          eventLoader: _getEventsForDay,
                          
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(color: AppTheme.primary300, shape: BoxShape.circle),
                            selectedDecoration: const BoxDecoration(color: AppTheme.primary500, shape: BoxShape.circle),
                            markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          ),
                          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
              
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            }
                          },
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() => _calendarFormat = format);
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Event List Side Panel
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: AppTheme.cardDecoration,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Events for ${_selectedDay?.day}/${_selectedDay?.month}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ..._getEventsForDay(_selectedDay!).map((event) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: AppTheme.primary50,
                               borderRadius: BorderRadius.circular(8),
                               border: Border.all(color: AppTheme.primary200),
                             ),
                            child: Row(
                              children: [
                                Container(width: 4, height: 40, color: AppTheme.primary600),
                                const SizedBox(width: 12),
                                Expanded(child: Text(event, style: const TextStyle(fontWeight: FontWeight.w500))),
                              ],
                            ),
                          )).toList(),
                          if (_getEventsForDay(_selectedDay!).isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: Text('No events scheduled', style: TextStyle(color: Colors.grey))),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
