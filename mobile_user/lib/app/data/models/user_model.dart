class UserModel {
  final String email;
  final String username;
  final String password;

  UserModel({
    required this.email,
    required this.username,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      username: json['username'],
      password: json['password'],
    );
  }
}
