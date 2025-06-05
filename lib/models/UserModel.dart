class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? role;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'],
      email: data['email'],
      role: data['role'],
    );
  }
}
