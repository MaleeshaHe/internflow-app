import 'package:flutter/material.dart';
import 'package:internflow/components/admin_content.dart';
import 'package:internflow/components/comparative_analytics.dart';
import 'package:internflow/components/intern_summary_card.dart';
import 'package:internflow/components/intern_work_details.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
import 'package:internflow/services/auth.dart';
import 'package:internflow/services/leave_data_service.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final AuthServices _auth = AuthServices();
  final LeaveDataService _leaveService = LeaveDataService();

  List<UserModel> _admins = [];
  List<UserModel> _interns = [];
  List<WorkUpdate> _workUpdates = [];
  Map<DateTime, List<String>> _leaveEvents = {};
  Map<String, String> _internNames = {};
  UserModel? _selectedIntern;
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
      final workUpdates = await _leaveService.getAllWorkUpdates();
      final interns = await _leaveService.getAllInterns();

      setState(() {
        _admins = admins;
        _interns = interns;
        _internNames = internNames;
        _leaveEvents = leaveEvents;
        _workUpdates = workUpdates;
        if (_interns.isNotEmpty) _selectedIntern = _interns.first;
      });
    } catch (e) {
      print('Error loading data: $e');
    }

    setState(() => _isLoading = false);
  }

  List<WorkUpdate> _getSelectedInternUpdates() {
    if (_selectedIntern == null) return [];
    return _workUpdates
        .where((update) => update.userId == _selectedIntern!.uid)
        .toList();
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
              child: Column(
                children: [
                  // Intern Selection Dropdown
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<UserModel>(
                      value: _selectedIntern,
                      isExpanded: true,
                      hint: const Text('Select Intern'),
                      items: _interns.map((intern) {
                        return DropdownMenuItem<UserModel>(
                          value: intern,
                          child: Text(intern.name ?? 'No Name'),
                        );
                      }).toList(),
                      onChanged: (UserModel? newValue) {
                        setState(() {
                          _selectedIntern = newValue;
                        });
                      },
                    ),
                  ),

                  // Selected Intern's Work Details
                  if (_selectedIntern != null)
                    InternWorkDetails(
                      intern: _selectedIntern!,
                      workUpdates: _getSelectedInternUpdates(),
                    ),

                  // Comparative Analytics
                  ComparativeAnalytics(
                    interns: _interns,
                    workUpdates: _workUpdates,
                  ),

                  // All Interns Summary
                  InternSummaryCard(workUpdates: _workUpdates),
                ],
              ),
            ),
    );
  }
}
