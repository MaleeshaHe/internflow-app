import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internflow/components/admin_view/dashboard_summary.dart';
import 'package:internflow/components/admin_view/intern_dropdown.dart';
import 'package:internflow/components/admin_view/leave_calendar.dart';
import 'package:internflow/components/admin_view/summary_statistics.dart';
import 'package:internflow/components/admin_view/work_overview_chart.dart';
import 'package:internflow/screens/home/intern_list_page.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedInternId;
  Map<String, dynamic> selectedInternData = {};
  List<DocumentSnapshot> interns = [];
  List<DocumentSnapshot> workUpdates = [];
  Map<DateTime, List<String>> leaveEvents = {};

  DateTime focusedDay = DateTime.now();
  int totalInterns = 0;
  int internsWithUpdates = 0;
  int internsWithoutUpdates = 0;

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  Future<void> fetchInterns() async {
    final internSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .get();

    final internDocs = internSnapshot.docs;
    final internIds = internDocs.map((doc) => doc['uid'] as String).toList();

    final updatesSnapshot =
        await FirebaseFirestore.instance.collection('work_updates').get();

    final updatedInternIds = updatesSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['userId'])
        .whereType<String>()
        .toSet();

    setState(() {
      interns = internDocs;
      totalInterns = internDocs.length;
      internsWithUpdates =
          internIds.where((id) => updatedInternIds.contains(id)).length;
      internsWithoutUpdates = totalInterns - internsWithUpdates;
    });
  }

  Future<void> fetchWorkUpdates(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('work_updates')
        .where('userId', isEqualTo: userId)
        .get();

    final updates = snapshot.docs;
    final events = <DateTime, List<String>>{};

    for (var doc in updates) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['onLeave'] == true) {
        DateTime? date;
        if (data['date'] != null) {
          if (data['date'] is Timestamp) {
            date = (data['date'] as Timestamp).toDate();
          } else if (data['date'] is String) {
            try {
              date = DateTime.parse(data['date']);
            } catch (_) {}
          }
        }

        if (date == null) {
          try {
            date = DateTime.fromMillisecondsSinceEpoch(int.parse(doc.id));
          } catch (_) {}
        }

        if (date != null) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          events[normalizedDate] = ['On Leave'];
        }
      }
    }

    setState(() {
      workUpdates = updates;
      leaveEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DashboardSummary(
              totalInterns: totalInterns,
              internsWithUpdates: internsWithUpdates,
              internsWithoutUpdates: internsWithoutUpdates,
              onViewAllPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InternListPage()),
                );
              },
            ),
            InternDropdown(
              interns: interns,
              selectedInternId: selectedInternId,
              onChanged: (String value, Map<String, dynamic> data) {
                setState(() {
                  selectedInternId = value;
                  selectedInternData = data;
                });
                fetchWorkUpdates(value);
              },
            ),
            const SizedBox(height: 20),
            if (selectedInternId != null) ...[
              Text(
                'Work Overview for ${selectedInternData['name'] ?? ''}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              WorkOverviewChart(workUpdates: workUpdates),
              const SizedBox(height: 20),
              SummaryStatistics(workUpdates: workUpdates),
              const SizedBox(height: 20),
              LeaveCalendar(
                focusedDay: focusedDay,
                leaveEvents: leaveEvents,
                calendarFormat: CalendarFormat
                    .month, // Add the required calendarFormat argument
                onFormatChanged: (format) {
                  setState(() {
                    // Update calendar format if needed
                  });
                },
                onDayTap: (selected, focused) {
                  // Replace with the correct parameter name as per LeaveCalendar definition
                  setState(() {
                    focusedDay = focused;
                  });
                },
                onPageChanged: (focused) {
                  setState(() {
                    focusedDay = focused;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
