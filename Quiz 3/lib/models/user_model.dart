class UserModel {
  int? id;
  String fullName;
  String email;
  String phone;
  String address;
  String gender;
  int? color;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      if (color != null) 'color': color,
    };
  }
}
