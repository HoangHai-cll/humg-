import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/auth.dart';

class JwtHelper {
  static String get _secret =>
      Platform.environment['JWT_SECRET'] ?? 'default-secret-key-change-me';

  static String get _issuer =>
      Platform.environment['JWT_ISSUER'] ?? 'quanlydaotao-api';

  static int get _expiryHours =>
      int.tryParse(Platform.environment['JWT_EXPIRY_HOURS'] ?? '24') ?? 24;

  /// Tạo JWT token cho user
  static String generateToken(Auth user) {
    final jwt = JWT(
      {
        'sub': user.id.toString(),
        'email': user.email,
        'msv': user.msv,
        'role': user.role.value,
      },
      issuer: _issuer,
    );

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: Duration(hours: _expiryHours),
    );
  }

  /// Verify và decode JWT token
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }

  /// Lấy user ID từ token
  static int? getUserIdFromToken(String token) {
    final payload = verifyToken(token);
    if (payload == null) return null;
    return int.tryParse(payload['sub'] as String? ?? '');
  }

  /// Lấy role từ token
  static UserRole? getRoleFromToken(String token) {
    final payload = verifyToken(token);
    if (payload == null) return null;
    return UserRole.fromString(payload['role'] as String? ?? 'sinhvien');
  }

  /// Lấy MSV từ token
  static String? getMsvFromToken(String token) {
    final payload = verifyToken(token);
    return payload?['msv'] as String?;
  }

  /// Kiểm tra token có phải admin không
  static bool isAdmin(String token) {
    final role = getRoleFromToken(token);
    return role == UserRole.admin;
  }

  /// Thời gian hết hạn tính bằng giây
  static int get expiryInSeconds => _expiryHours * 3600;
}
