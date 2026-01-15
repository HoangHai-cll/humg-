class User {
  final String id;
  final String? msv;
  final String email;
  final String? hoTen;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    this.msv,
    required this.email,
    this.hoTen,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      msv: json['msv'],
      email: json['email'] ?? '',
      hoTen: json['ho_ten'],
      role: json['role'] ?? 'sinhvien',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'msv': msv,
      'email': email,
      'ho_ten': hoTen,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isSinhVien => role == 'sinhvien';
}
