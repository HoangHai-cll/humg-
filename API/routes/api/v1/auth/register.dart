import 'dart:async';

import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/models/auth.dart';
import 'package:quanlydaotao_api_backend/repositories/auth_repository.dart';
import 'package:quanlydaotao_api_backend/repositories/sinh_vien_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
import 'package:quanlydaotao_api_backend/utils/jwt_helper.dart';
import 'package:quanlydaotao_api_backend/utils/password_helper.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _register(context),
    _ => ApiResponse.error(message: 'Method not allowed', statusCode: 405),
  };
}

Future<Response> _register(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Validate input
    final errors = <String, String>{};

    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final msv = body['msv'] as String?;

    if (email == null || email.isEmpty) {
      errors['email'] = 'Email là bắt buộc';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors['email'] = 'Email không hợp lệ';
    }

    if (password == null || password.isEmpty) {
      errors['password'] = 'Mật khẩu là bắt buộc';
    } else {
      final passwordValidation = PasswordHelper.validatePassword(password);
      if (!(passwordValidation['valid'] as bool)) {
        errors['password'] =
            (passwordValidation['errors'] as List).first as String;
      }
    }

    // Nếu có MSV, kiểm tra sinh viên tồn tại
    if (msv != null && msv.isNotEmpty) {
      final svRepo = SinhVienRepository();
      final sv = svRepo.findByMsv(msv);
      if (sv == null) {
        errors['msv'] = 'Mã sinh viên không tồn tại trong hệ thống';
      }
    }

    if (errors.isNotEmpty) {
      return ApiResponse.validationError(
        message: 'Dữ liệu không hợp lệ',
        errors: errors,
      );
    }

    final registerDto = RegisterDto(
      email: email!,
      password: password!,
      msv: msv,
      role: 'sinhvien', // Chỉ cho đăng ký sinh viên, admin tạo qua route khác
    );

    final authRepo = AuthRepository();
    final user = authRepo.register(registerDto);

    if (user == null) {
      return ApiResponse.serverError(message: 'Không thể tạo tài khoản');
    }

    final token = JwtHelper.generateToken(user);
    final authResponse = AuthResponse(
      accessToken: token,
      expiresIn: JwtHelper.expiryInSeconds,
      user: user.toSafeMap(),
    );

    return ApiResponse.created(
      data: authResponse.toMap(),
      message: 'Đăng ký thành công',
    );
  } on Exception catch (e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    return ApiResponse.error(message: message);
  }
}
