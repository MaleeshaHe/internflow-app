import 'package:flutter/material.dart';
import 'package:internflow/components/admin_content.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/services/auth.dart';
import 'package:internflow/services/leave_data_service.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final AuthServices _auth = AuthServices();
  final LeaveDataService _leaveService = LeaveDataService();

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
      final (admins, internNames, leaveEvents) =
          await _leaveService.getAllLeaveData();
      _admins = admins;
      _internNames = internNames;
      _leaveEvents = leaveEvents;
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => _isLoading = false);
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
          : AdminContent(
              admins: _admins,
              internNames: _internNames,
              leaveEvents: _leaveEvents,
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
              onRefresh: _loadData,
            ),
    );
  }
}
