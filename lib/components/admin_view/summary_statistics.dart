import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryStatistics extends StatelessWidget {
  final List<DocumentSnapshot> workUpdates;

  const SummaryStatistics({super.key, required this.workUpdates});

  @override
  Widget build(BuildContext context) {
    int workDays = 0, leaveDays = 0;
    double hours = 0;
    for (var doc in workUpdates) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['onLeave'] == true) {
        leaveDays++;
      } else {
        workDays++;
      }
      if (data['hoursWorked'] != null) {
        hours += data['hoursWorked'];
      }
    }
    final attendance = workDays + leaveDays == 0
        ? 0
        : (workDays / (workDays + leaveDays)) * 100;

    Widget _stat(String label, String value, Color color) {
      return Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Attendance Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat("Work Days", "$workDays", Colors.green),
            _stat("Leave Days", "$leaveDays", Colors.red),
            _stat(
                "Attendance", "${attendance.toStringAsFixed(1)}%", Colors.blue),
          ],
        ),
      ],
    );
  }
}
