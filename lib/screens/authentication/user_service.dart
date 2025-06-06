import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internflow/models/UserModel.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }
}
