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
  Future<WorkUpdate?> getDailyUpdate(DateTime date, {String? userId}) async {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return null;

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final documentId = "${uid}_$formattedDate";

    try {
      final doc =
          await _firestore.collection('work_updates').doc(documentId).get();
      if (doc.exists) {
        return WorkUpdate.fromJson(doc.data()!);
      }
    } catch (e) {
      print("Error fetching daily update: $e");
    }

    return null;
  }

  /// Fetches work updates for a full week starting from [startOfWeek].
  Future<List<WorkUpdate>> getWeeklyUpdates(DateTime startOfWeek,
      {String? userId}) async {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return [];

    // Generate list of all 7 date strings for the week
    final dateStrings = List.generate(7, (i) {
      final date = startOfWeek.add(Duration(days: i));
      return DateFormat('yyyy-MM-dd').format(date);
    });

    try {
      final snapshot = await _firestore
          .collection('work_updates')
          .where('userId', isEqualTo: uid)
          .where('date', whereIn: dateStrings)
          .get();

      return snapshot.docs
          .map((doc) => WorkUpdate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching weekly updates: $e");
      return [];
    }
  }

  Future<List<WorkUpdate>> getAllUpdatesForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('work_updates')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => WorkUpdate.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching all updates: $e");
      return [];
    }
  }

  // Backfills missing date fields based on submittedAt
  Future<void> backfillMissingDates(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('work_updates')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (!data.containsKey('date') ||
            data['date'] == null ||
            data['date'].isEmpty) {
          final submittedAt = DateTime.parse(data['submittedAt']);
          final newDate = DateFormat('yyyy-MM-dd').format(submittedAt);
          await doc.reference.update({'date': newDate});
          print("Backfilled date for doc ${doc.id} to $newDate");
        }
      }
    } catch (e) {
      print("Error backfilling dates: $e");
    }
  }
}
