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
    await _fetchWorkUpdates(); // Wait for work updates to finish
  }

  Future<void> _fetchWorkUpdates() async {
    if (_userModel == null) return;
    setState(() => _isLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('work_updates')
        .where('userId', isEqualTo: _userModel!.uid)
        .get();

    setState(() {
      _workUpdates = snapshot.docs
          .map((doc) => WorkUpdate.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      _isLoading = false;
    });
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
  void initState() {
    super.initState();
    _fetchUserDetails();
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
            onPressed: () async {
              await _fetchUserDetails();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
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
                      if (_workUpdates.isEmpty)
                        const Center(child: Text('No work updates found.')),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserHeader(ThemeData theme) {
    if (_userModel == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          leading: const CircleAvatar(
            radius: 28,
            child: Icon(Icons.person, size: 32),
          ),
          title: Text(
            _userModel!.name ?? '',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Email: ${_userModel!.email}'),
              Text('Role: ${_userModel!.role}'),
              Text('UID: ${_userModel!.uid}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit_calendar),
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
