import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final Map<DateTime, List<String>> leaveEvents;

  const LeaveCalendar({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.leaveEvents, required Null Function(dynamic selected, dynamic focused) onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          eventLoader: (day) =>
              leaveEvents[DateTime(day.year, day.month, day.day)] ?? [],
          calendarStyle: CalendarStyle(
            markerDecoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            markerSize: 8,
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
          ),
        ),
      ),
    );
  }
}
