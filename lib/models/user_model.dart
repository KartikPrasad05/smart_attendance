class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // student | professor | admin
  final String passwordHash;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.passwordHash,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        passwordHash: json['password_hash'],
      );
}
