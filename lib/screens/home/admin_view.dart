import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/screens/home/work_update_detail_page.dart';
import 'package:internflow/screens/home/work_update_screen.dart';
import 'package:internflow/services/auth.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final AuthServices _auth = AuthServices();
  List<UserModel> _admins = [];
  List<UserModel> _interns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final allUsers = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      _admins = allUsers.where((user) => user.role == 'admin').toList();
      _interns = allUsers.where((user) => user.role == 'intern').toList();
    } catch (e) {
      print('Error loading users: $e');
    }

    setState(() => _isLoading = false);
  }

  Widget _buildUserCard(UserModel user, {bool isAdmin = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isAdmin ? Colors.blue.shade50 : null,
      child: ListTile(
        title: Text(user.name ?? ''),
        subtitle: Text(user.email ?? ''),
        trailing: isAdmin
            ? const Icon(Icons.shield)
            : const Icon(Icons.arrow_forward_ios),
        onTap: isAdmin
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkUpdateDetailPage(userId: user.uid),
                  ),
                );
              },
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
            icon: const Icon(Icons.logout),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admins:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_admins.isEmpty)
                    const Text('No admins found.')
                  else
                    ..._admins
                        .map((admin) => _buildUserCard(admin, isAdmin: true)),
                  const Divider(height: 30, thickness: 1.5),
                  const Text('Interns:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _interns.isEmpty
                        ? const Center(child: Text('No interns found.'))
                        : ListView.builder(
                            itemCount: _interns.length,
                            itemBuilder: (context, index) =>
                                _buildUserCard(_interns[index]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
