class UserModel {
  int id;
  String userName;
  String password;
  bool isDoctor;
  String useridentification;
  UserModel({
    required this.id,
    required this.userName,
    required this.password,
    required this.isDoctor,
    required this.useridentification,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      userName: json['username'] ?? '',
      password: json['password'] ?? '',
      isDoctor: json['isDoctor'] ?? false,
      useridentification: json['useridentification'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, userName: $userName, password: $password, isDoctor: $isDoctor, useridentification: $useridentification)';
  }
}
