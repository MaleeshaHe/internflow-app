import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/screens/home/intern_list_page.dart';
import 'package:internflow/components/admin_list_widget.dart';
import 'package:internflow/components/leave_calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'admin_leave_dialog.dart';

class AdminContent extends StatelessWidget {
  final Map<String, String> internNames;
  final Map<DateTime, List<String>> leaveEvents;
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final VoidCallback onRefresh;

  const AdminContent({
    super.key,
    required this.internNames,
    required this.leaveEvents,
    required this.calendarFormat,
    required this.focusedDay,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.onRefresh, required List<UserModel> admins,
  });

  List<String> _getUsersOnLeave(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return leaveEvents[key]?.toSet().toList() ?? [];
  }

  void _showLeaveDialog(BuildContext context, DateTime date) {
    final uids = _getUsersOnLeave(date);
    final names = uids.map((uid) => internNames[uid] ?? 'Unknown').toList();

    showDialog(
      context: context,
      builder: (context) => AdminLeaveDialog(date: date, names: names),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('View Interns'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InternListPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Intern Leaves Calendar:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LeaveCalendarWidget(
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
            onDayTapped: (day) => _showLeaveDialog(context, day),
            getEvents: _getUsersOnLeave,
          ),
        ],
      ),
    );
  }
}
