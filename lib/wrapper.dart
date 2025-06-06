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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const Authenticate();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError ||
                !userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text('Failed to retrieve user data')),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = userData['role'] as String?;

            if (role == 'admin') {
              return const AdminView();
            } else if (role == 'intern') {
              return const InternView();
            } else {
              return const Scaffold(
                body: Center(child: Text('Unknown role')),
              );
            }
          },
        );
      },
    );
  }
}
