import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internflow/models/UserModel.dart';
import 'package:internflow/models/WorkUpdateModel.dart';

class LeaveDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAdmins() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
    return users.where((u) => u.role == 'admin').toList();
  }

  Future<Map<String, String>> getInternNames() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();

    final internNames = <String, String>{};
    for (var user in users.where((u) => u.role == 'intern')) {
      internNames[user.uid] = user.name ?? 'Unnamed Intern';
    }

    return internNames;
  }

  Future<Map<DateTime, List<String>>> getLeaveEvents() async {
    final logSnapshot = await _firestore.collection('work_updates').get();
    final leaveEvents = <DateTime, List<String>>{};

    for (var doc in logSnapshot.docs) {
      final data = doc.data();
      if ((data['onLeave'] ?? false) == true) {
        final submittedAtStr = data['submittedAt'];
        final DateTime ts = DateTime.parse(submittedAtStr);
        final DateTime date = DateTime.utc(ts.year, ts.month, ts.day);
        final uid = data['userId'] as String;

        leaveEvents.update(
          date,
          (existing) => {...existing, uid}.toList(),
          ifAbsent: () => [uid],
        );
      }
    }

    return leaveEvents;
  }

  /// Combined helper if you want to get everything at once
  Future<(List<UserModel>, Map<String, String>, Map<DateTime, List<String>>)>
      getAllLeaveData() async {
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();

    final admins = users.where((u) => u.role == 'admin').toList();
    final internNames = <String, String>{};
    for (var user in users.where((u) => u.role == 'intern')) {
      internNames[user.uid] = user.name ?? 'Unnamed Intern';
    }

    final leaveEvents = await getLeaveEvents();

    return (admins, internNames, leaveEvents);
  }

  Future<List<WorkUpdate>> getAllWorkUpdates() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('work_updates').get();

    return snapshot.docs.map((doc) => WorkUpdate.fromMap(doc.data())).toList();
  }
}
