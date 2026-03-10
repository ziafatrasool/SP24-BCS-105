import 'dart:convert';

class Patient {
  const Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.diagnosis,
    required this.notes,
    required this.lastVisitIso,
    required this.avatarPath,
    required this.documentPaths,
  });

  final int? id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String diagnosis;
  final String notes;
  final String lastVisitIso;
  final String? avatarPath;
  final List<String> documentPaths;

  Patient copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? diagnosis,
    String? notes,
    String? lastVisitIso,
    String? avatarPath,
    List<String>? documentPaths,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      lastVisitIso: lastVisitIso ?? this.lastVisitIso,
      avatarPath: avatarPath ?? this.avatarPath,
      documentPaths: documentPaths ?? this.documentPaths,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'diagnosis': diagnosis,
      'notes': notes,
      'lastVisitIso': lastVisitIso,
      'avatarPath': avatarPath,
      'documentPaths': jsonEncode(documentPaths),
    };
  }

  static Patient fromMap(Map<String, Object?> map) {
    return Patient(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      age: (map['age'] as int?) ?? 0,
      gender: (map['gender'] as String?) ?? 'Not set',
      phone: (map['phone'] as String?) ?? '',
      diagnosis: (map['diagnosis'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      lastVisitIso: (map['lastVisitIso'] as String?) ?? '',
      avatarPath: map['avatarPath'] as String?,
      documentPaths: _decodePaths(map['documentPaths']),
    );
  }

  static List<String> _decodePaths(Object? raw) {
    if (raw == null) {
      return <String>[];
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    }
    return <String>[];
  }
}
