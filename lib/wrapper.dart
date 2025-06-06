import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internflow/screens/authentication/authenticate.dart';
import 'package:internflow/screens/home/admin_view.dart';
import 'package:internflow/screens/home/intern_view.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        final user = authSnapshot.data;
        return user == null ? const Authenticate() : _buildUserRoleView(user);
      },
    );
  }

  Widget _buildUserRoleView(User user) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return _buildError('Failed to retrieve user data');
        }

        final role =
            (userSnapshot.data!.data() as Map<String, dynamic>)['role'];

        switch (role) {
          case 'admin':
            return const AdminView();
          case 'intern':
            return const InternView();
          default:
            return _buildError('Unknown role');
        }
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}
