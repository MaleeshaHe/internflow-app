import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final void Function(CalendarFormat) onFormatChanged;
  final void Function(DateTime) onDayTapped;
  final void Function(DateTime) onPageChanged;
  final List<String> Function(DateTime) getEvents;

  const LeaveCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onFormatChanged,
    required this.onDayTapped,
    required this.onPageChanged,
    required this.getEvents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
          eventLoader: getEvents,
          onDaySelected: (selectedDay, focusedDay) {
            onDayTapped(selectedDay);
          },
          calendarStyle: CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Colors.red.shade400,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 10,
            markerSize: 8,
            markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey),
            ),
            formatButtonTextStyle: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
