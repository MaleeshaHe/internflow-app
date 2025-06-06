import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  String? selectedInternId;
  Map<String, dynamic> selectedInternData = {};
  List<DocumentSnapshot> interns = [];
  List<DocumentSnapshot> workUpdates = [];

  Map<DateTime, List<String>> leaveEvents = {};
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    fetchInterns();
  }

  Future<void> fetchInterns() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .get();
    setState(() {
      interns = snapshot.docs;
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
      if (data['onLeave'] == true && data['date'] != null) {
        try {
          final date = DateTime.parse(data['date']);
          final normalized = DateTime(date.year, date.month, date.day);
          events[normalized] = ['On Leave'];
        } catch (_) {}
      }
    }

    setState(() {
      workUpdates = updates;
      leaveEvents = events;
    });
  }

  Widget buildInternDropdown() {
    return DropdownButton<String>(
      hint: const Text('Select Intern'),
      value: selectedInternId,
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
        const SizedBox(height: 10),
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
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
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
                markersMaxCount: 5,
                markerSize: 12,
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
                  fontSize: 14,
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
        title: const Text('Admin View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
