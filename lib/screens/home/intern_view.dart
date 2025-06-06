import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internflow/components/intern_action_button.dart';
import 'package:internflow/components/intern_header.dart';
import 'package:internflow/components/intern_summary_card.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
import 'package:internflow/screens/authentication/user_service.dart';
import 'package:internflow/services/auth.dart';
import 'package:internflow/services/work_update_service.dart';

class InternView extends StatefulWidget {
  const InternView({super.key});

  @override
  State<InternView> createState() => _InternViewState();
}

class _InternViewState extends State<InternView> {
  final AuthServices _auth = AuthServices();
  final WorkUpdateService _workUpdateService = WorkUpdateService();

  UserModel? _userModel;
  List<WorkUpdate> _workUpdates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final user = await UserService().getUserById(uid);
      final updates = await _workUpdateService.getAllUpdatesForUser(uid);

      setState(() {
        _userModel = user;
        _workUpdates = updates;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async => await _auth.signOut()),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userModel == null
              ? const Center(child: Text('No user data found'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      InternHeader(user: _userModel!),
                      const SizedBox(height: 20),
                      const InternActionButton(),
                      const SizedBox(height: 20),
                      InternSummaryCard(workUpdates: _workUpdates),
                    ],
                  ),
                ),
    );
  }
}
