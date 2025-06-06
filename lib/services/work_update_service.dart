import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internflow/models/WorkUpdateModel.dart';
import 'package:intl/intl.dart';

class WorkUpdateService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Submits a daily work update for the current user.
  Future<String?> submitDailyUpdate({
    required bool plan,
    required bool coding,
    required bool debugging,
    required bool testing,
    required bool waiting,
    required bool onLeave,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return 'User not logged in.';

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final documentId = "${user.uid}_$formattedDate";

    final update = WorkUpdate(
      userId: user.uid,
      date: formattedDate,
      plan: plan,
      coding: coding,
      debugging: debugging,
      testing: testing,
      waiting: waiting,
      onLeave: onLeave,
      description: description,
      submittedAt: DateTime.now().toUtc().toIso8601String(),
    );

    try {
      await _firestore
          .collection('work_updates')
          .doc(documentId)
          .set(update.toJson());

      return null; // success
    } catch (e) {
      return 'Failed to submit update: ${e.toString()}';
    }
  }

  /// Fetches the current user's work update for a specific date.
  Future<WorkUpdate?> getDailyUpdate(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final documentId = "${user.uid}_$formattedDate";

    try {
      final doc =
          await _firestore.collection('work_updates').doc(documentId).get();
      if (doc.exists) {
        return WorkUpdate.fromJson(doc.data()!);
      }
    } catch (e) {
      print("Error fetching update: $e");
    }

    return null;
  }
}
