import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internflow/screens/home/intern_list_page.dart';
import 'package:pie_chart/pie_chart.dart';
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
  CalendarFormat calendarFormat = CalendarFormat.month;

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
              date = DateTime.parse(data['date'] as String);
            } catch (e) {
              print('Error parsing date string: ${data['date']}');
            }
          }
        }

        if (date == null) {
          try {
            date = DateTime.fromMillisecondsSinceEpoch(int.parse(doc.id));
          } catch (e) {
            print('Error parsing date from document ID: ${doc.id}');
          }
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

  Widget buildDashboardSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            SizedBox(width: 8),
            Text(
              "Intern Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard("Total Interns", "$totalInterns", Colors.deepPurple),
            _buildStatCard("With Updates", "$internsWithUpdates", Colors.green),
            _buildStatCard("No Updates", "$internsWithoutUpdates", Colors.red),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InternListPage()),
              );
            },
            icon:
                const Icon(Icons.people_outline, size: 20, color: Colors.white),
            label: const Text(
              "View All Interns",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildInternDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedInternId,
          hint: const Text(
            'Select Intern',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          isExpanded: true,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          onChanged: (value) {
            setState(() {
              selectedInternId = value;
              selectedInternData = interns
                  .firstWhere((doc) => doc['uid'] == value)
                  .data() as Map<String, dynamic>;
            });
            fetchWorkUpdates(value!);
          },
          items: interns.map((doc) {
            final name = doc['name'];
            final uid = doc['uid'];
            return DropdownMenuItem<String>(
              value: uid,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildWorkOverviewChart() {
    if (workUpdates.isEmpty) {
      return const Text('No work updates available.');
    }

    int codingCount = 0;
    int planCount = 0;
    int debuggingCount = 0;
    int testingCount = 0;
    int onLeaveCount = 0;

    for (var doc in workUpdates) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['coding'] == true) codingCount++;
      if (data['plan'] == true) planCount++;
      if (data['debugging'] == true) debuggingCount++;
      if (data['testing'] == true) testingCount++;
      if (data['onLeave'] == true) onLeaveCount++;
    }

    final dataMap = {
      "Coding": codingCount.toDouble(),
      "Planning": planCount.toDouble(),
      "Debugging": debuggingCount.toDouble(),
      "Testing": testingCount.toDouble(),
      "On Leave": onLeaveCount.toDouble(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        PieChart(
          dataMap: dataMap,
          chartType: ChartType.disc,
          chartRadius: MediaQuery.of(context).size.width / 2.2,
          legendOptions: const LegendOptions(
            showLegends: true,
            legendPosition: LegendPosition.right,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
          ),
        ),
      ],
    );
  }

  Widget buildLeaveCalendar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Intern Leave Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: focusedDay,
              calendarFormat: calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
              onPageChanged: (focused) {
                setState(() {
                  focusedDay = focused;
                });
              },
              onDaySelected: (selectedDay, focused) {
                setState(() {
                  focusedDay = focused;
                });
              },
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return leaveEvents[key] ?? [];
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 8,
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
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
          ],
        ),
      ),
    );
  }

  Widget buildSummaryStatistics() {
    if (workUpdates.isEmpty) return const Text("No data available.");

    int workDays = 0;
    int leaveDays = 0;
    double totalHours = 0;
    Map<String, int> moodCounts = {};

    for (var doc in workUpdates) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['onLeave'] == true) {
        leaveDays++;
      } else {
        workDays++;
      }
      if (data['hoursWorked'] != null) {
        totalHours += data['hoursWorked'];
      }
      if (data['mood'] != null) {
        moodCounts[data['mood']] = (moodCounts[data['mood']] ?? 0) + 1;
      }
    }

    int totalDays = workDays + leaveDays;
    double attendancePercentage =
        totalDays == 0 ? 0 : (workDays / totalDays) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Attendance Summary",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard("Work Days", "$workDays", Colors.green),
            _buildStatCard("Leave Days", "$leaveDays", Colors.red),
            _buildStatCard("Attendance",
                "${attendancePercentage.toStringAsFixed(1)}%", Colors.blue),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 110,
        height: 90,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async => await _auth.signOut()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildDashboardSummary(),
            buildInternDropdown(),
            const SizedBox(height: 20),
            if (selectedInternId != null) ...[
              Text(
                'Work Overview for ${selectedInternData['name'] ?? ''}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              buildWorkOverviewChart(),
              const SizedBox(height: 20),
              buildSummaryStatistics(),
              const SizedBox(height: 20),
              buildLeaveCalendar(),
            ],
          ],
        ),
      ),
    );
  }
}
