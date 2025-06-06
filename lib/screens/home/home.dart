import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/screens/home/work_update_screen.dart';
import 'package:internflow/services/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthServices _auth = AuthServices();

  UserModel? _userModel;
  bool _isLoading = true;

  Future<void> _fetchUserDetails() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        setState(() {
          _userModel = UserModel.fromMap(doc.data()!, uid);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, ${_userModel!.name}',
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      Text('Email: ${_userModel!.email}'),
                      Text('Role: ${_userModel!.role}'),
                      Text('UID: ${_userModel!.uid}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WorkUpdateScreen(userId: '',)),
                          );
                        },
                        child: const Text('Submit Daily Work Update'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
    );
  }
}
