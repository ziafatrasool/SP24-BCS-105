class Submission {
  final String? id;
  final DateTime? createdAt;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;

  Submission({
    this.id,
    this.createdAt,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
    };
  }
}
