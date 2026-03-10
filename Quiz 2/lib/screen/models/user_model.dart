class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String gender;
  final String? image;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'gender': gender,
      'image': image,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      gender: map['gender'] as String,
      image: map['image'] as String?,
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? gender,
    String? image,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      image: image ?? this.image,
    );
  }
}
