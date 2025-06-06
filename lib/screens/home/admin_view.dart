import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/screens/home/intern_list_page.dart';
import 'package:internflow/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final AuthServices _auth = AuthServices();
  List<UserModel> _admins = [];
  Map<DateTime, List<String>> _leaveEvents = {};
  Map<String, String> _internNames = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final users = userSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      _admins = users.where((u) => u.role == 'admin').toList();

      for (var user in users.where((u) => u.role == 'intern')) {
        _internNames[user.uid] = user.name ?? 'Unnamed Intern';
      }

      final logSnapshot =
          await FirebaseFirestore.instance.collection('work_updates').get();

      for (var doc in logSnapshot.docs) {
        final data = doc.data();
        if ((data['onLeave'] ?? false) == true) {
          final String submittedAtStr = data['submittedAt'];
          final DateTime ts = DateTime.parse(submittedAtStr);
          final DateTime date = DateTime.utc(ts.year, ts.month, ts.day);
          final uid = data['userId'] as String;

          _leaveEvents.update(
            date,
            (existing) => {...existing, uid}.toList(), // avoid duplicates
            ifAbsent: () => [uid],
          );
        }
      }
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  List<String> _getUsersOnLeave(DateTime day) {
    // Normalize the day to UTC to match our keys
    final key = DateTime.utc(day.year, day.month, day.day);
    return _leaveEvents[key]?.toSet().toList() ?? []; // Remove duplicates
  }

  void _showLeaveDialog(DateTime date) {
    final uids = _getUsersOnLeave(date);
    final names = uids.map((uid) => _internNames[uid] ?? 'Unknown').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Interns on leave - ${DateFormat('MMM dd, yyyy').format(date)}',
          style: const TextStyle(fontSize: 18),
        ),
        content: names.isEmpty
            ? const Text('No interns on leave this day.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: names.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(names[index]),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admins:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_admins.isEmpty)
                    const Text('No admins found.')
                  else
                    ..._admins.map((admin) => Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Colors.blue.shade50,
                          child: ListTile(
                            title: Text(admin.name ?? ''),
                            subtitle: Text(admin.email ?? ''),
                            trailing: const Icon(Icons.shield),
                          ),
                        )),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.people),
                      label: const Text('View Interns'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InternListPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Intern Leaves Calendar:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        onPageChanged: (focusedDay) {
                          setState(() => _focusedDay = focusedDay);
                        },
                        calendarStyle: CalendarStyle(
                          markerDecoration: BoxDecoration(
                            color: Colors.red.shade400,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 2, // allow up to 10 dots per day
                          markerSize: 10, // slightly smaller for more space
                          markerMargin:
                              const EdgeInsets.symmetric(horizontal: 0.5),
                        ),
                        eventLoader: (day) {
                          // Return one item per intern on leave
                          return _getUsersOnLeave(day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                          _showLeaveDialog(selectedDay);
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          formatButtonTextStyle:
                              const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
