import 'dart:convert';

enum UserRole {
  admin,
  sinhvien;

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.sinhvien:
        return 'sinhvien';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'sinhvien':
        return UserRole.sinhvien;
      default:
        return UserRole.sinhvien;
    }
  }
}

class Auth {
  final int id;
  final String? msv; // Null nếu là admin
  final String email;
  final String password; // Đã hash
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Auth({
    required this.id,
    this.msv,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Auth.fromMap(Map<String, dynamic> map) {
    return Auth(
      id: map['id'] as int,
      msv: map['msv'] as String?,
      email: map['email'] as String,
      password: map['password'] as String,
      role: UserRole.fromString(map['role'] as String? ?? 'sinhvien'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'msv': msv,
      'email': email,
      'password': password,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Trả về map không bao gồm password (cho response)
  Map<String, dynamic> toSafeMap() {
    return {
      'id': id,
      'msv': msv,
      'email': email,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Auth.fromJson(String source) =>
      Auth.fromMap(jsonDecode(source) as Map<String, dynamic>);

  bool get isAdmin => role == UserRole.admin;
  bool get isSinhVien => role == UserRole.sinhvien;

  Auth copyWith({
    int? id,
    String? msv,
    String? email,
    String? password,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Auth(
      id: id ?? this.id,
      msv: msv ?? this.msv,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Auth(id: $id, msv: $msv, email: $email, role: ${role.value})';
  }
}

/// DTO cho đăng ký
class RegisterDto {
  final String? msv;
  final String email;
  final String password;
  final String? role;

  RegisterDto({
    this.msv,
    required this.email,
    required this.password,
    this.role,
  });

  factory RegisterDto.fromMap(Map<String, dynamic> map) {
    return RegisterDto(
      msv: map['msv'] as String?,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String?,
    );
  }
}

/// DTO cho đăng nhập
class LoginDto {
  final String email;
  final String password;

  LoginDto({
    required this.email,
    required this.password,
  });

  factory LoginDto.fromMap(Map<String, dynamic> map) {
    return LoginDto(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}

/// Response chứa token
class AuthResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final Map<String, dynamic> user;

  AuthResponse({
    required this.accessToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user,
    };
  }
}
