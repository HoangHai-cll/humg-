import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHelper {
  /// Hash password với SHA256
  /// Lưu ý: Trong production nên dùng bcrypt thay vì SHA256
  static String hash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password
  static bool verify(String password, String hashedPassword) {
    return hash(password) == hashedPassword;
  }

  /// Validate password strength
  static Map<String, dynamic> validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 6) {
      errors.add('Mật khẩu phải có ít nhất 6 ký tự');
    }
    if (password.length > 100) {
      errors.add('Mật khẩu không được quá 100 ký tự');
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      errors.add('Mật khẩu phải chứa ít nhất một chữ cái');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Mật khẩu phải chứa ít nhất một chữ số');
    }

    return {
      'valid': errors.isEmpty,
      'errors': errors,
    };
  }
}
