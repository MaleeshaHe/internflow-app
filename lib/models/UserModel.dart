import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? role;
  final DateTime? joinDate;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.role,
    this.joinDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'],
      email: data['email'],
      role: data['role'],
      joinDate: (data['joinDate'] as Timestamp).toDate(),
    );
  }
}
