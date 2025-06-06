import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
import 'package:internflow/screens/home/work_update_screen.dart';
import 'package:internflow/services/auth.dart';

class InternView extends StatefulWidget {
  const InternView({super.key});

  @override
  State<InternView> createState() => _InternViewState();
}

class _InternViewState extends State<InternView> {
  final AuthServices _auth = AuthServices();

  UserModel? _userModel;
  bool _isLoading = true;
  List<WorkUpdate> _workUpdates = [];
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Plan',
    'Coding',
    'Debugging',
    'Testing',
    'Waiting',
    'On Leave',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        setState(() {
          _userModel = UserModel.fromMap(doc.data()!, uid);
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    await _fetchWorkUpdates();
  }

  Future<void> _fetchWorkUpdates() async {
    if (_userModel == null) return;
    setState(() => _isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('work_updates')
        .where('userId', isEqualTo: _userModel!.uid)
        .get();

    setState(() {
      _workUpdates =
          snapshot.docs.map((doc) => WorkUpdate.fromJson(doc.data())).toList();
      _isLoading = false;
    });
  }

  List<WorkUpdate> _filteredUpdates() {
    if (_selectedFilter == 'All') return _workUpdates;

    return _workUpdates.where((update) {
      switch (_selectedFilter) {
        case 'Plan':
          return update.plan;
        case 'Coding':
          return update.coding;
        case 'Debugging':
          return update.debugging;
        case 'Testing':
          return update.testing;
        case 'Waiting':
          return update.waiting;
        case 'On Leave':
          return update.onLeave;
        default:
          return false;
      }
    }).toList();
  }

  Map<String, int> _getStats() {
    final stats = {
      'Plan': 0,
      'Coding': 0,
      'Debugging': 0,
      'Testing': 0,
      'Waiting': 0,
      'On Leave': 0,
    };
    for (var update in _workUpdates) {
      if (update.plan) stats['Plan'] = stats['Plan']! + 1;
      if (update.coding) stats['Coding'] = stats['Coding']! + 1;
      if (update.debugging) stats['Debugging'] = stats['Debugging']! + 1;
      if (update.testing) stats['Testing'] = stats['Testing']! + 1;
      if (update.waiting) stats['Waiting'] = stats['Waiting']! + 1;
      if (update.onLeave) stats['On Leave'] = stats['On Leave']! + 1;
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserDetails,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userModel == null
              ? const Center(child: Text('No user data found'))
              : RefreshIndicator(
                  onRefresh: _fetchUserDetails,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildUserHeader(theme),
                      const SizedBox(height: 20),
                      _buildActionButton(),
                      const SizedBox(height: 20),
                      _buildSummaryCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserHeader(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userModel?.name ?? 'Intern',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _userModel?.email ?? '',
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.badge, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _userModel?.role ?? 'N/A',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Submit Daily Work Update'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WorkUpdateScreen()),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final stats = _getStats();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Work Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Total Updates: ${_workUpdates.length}'),
            const SizedBox(height: 10),
            ...stats.entries.map((entry) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(entry.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
