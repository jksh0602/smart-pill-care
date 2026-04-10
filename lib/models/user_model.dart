// lib/models/user_model.dart

enum UserRole { elder, guardian }

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String snrCode;     // 고유 관리 번호 (예: SNR-A3F7)
  final int? age;           // 어르신만 해당
  final List<String> linkedElderCodes; // 보호자가 연결한 어르신 SNR 코드 목록
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.snrCode,
    this.age,
    this.linkedElderCodes = const [],
    required this.createdAt,
  });

  bool get isElder => role == UserRole.elder;
  bool get isGuardian => role == UserRole.guardian;

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] == 'elder' ? UserRole.elder : UserRole.guardian,
      snrCode: map['snrCode'] ?? '',
      age: map['age'],
      linkedElderCodes: List<String>.from(map['linkedElderCodes'] ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'role': role == UserRole.elder ? 'elder' : 'guardian',
    'snrCode': snrCode,
    'age': age,
    'linkedElderCodes': linkedElderCodes,
    'createdAt': createdAt,
  };

  AppUser copyWith({List<String>? linkedElderCodes}) => AppUser(
    uid: uid,
    email: email,
    name: name,
    role: role,
    snrCode: snrCode,
    age: age,
    linkedElderCodes: linkedElderCodes ?? this.linkedElderCodes,
    createdAt: createdAt,
  );
}
