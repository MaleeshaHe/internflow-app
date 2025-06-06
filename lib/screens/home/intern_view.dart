import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internflow/components/intern_action_button.dart';
import 'package:internflow/components/intern_header.dart';
import 'package:internflow/components/intern_summary_card.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
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

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intern Dashboard'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _fetchUserDetails),
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
                  onRefresh: _fetchUserDetails,
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
