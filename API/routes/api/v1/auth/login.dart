import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/models/auth.dart';
import 'package:quanlydaotao_api_backend/repositories/auth_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
import 'package:quanlydaotao_api_backend/utils/jwt_helper.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _login(context),
    _ => ApiResponse.error(message: 'Method not allowed', statusCode: 405),
  };
}

// POST: /api/v1/auth/login
Future<Response> _login(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Validate input
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || email.isEmpty) {
      return ApiResponse.validationError(
        message: 'Email là bắt buộc',
        errors: {'email': 'Trường này là bắt buộc'},
      );
    }

    if (password == null || password.isEmpty) {
      return ApiResponse.validationError(
        message: 'Mật khẩu là bắt buộc',
        errors: {'password': 'Trường này là bắt buộc'},
      );
    }

    final loginDto = LoginDto(email: email, password: password);
    final authRepo = AuthRepository();

    final user = authRepo.authenticate(loginDto);
    if (user == null) {
      return ApiResponse.unauthorized(
          message: 'Email hoặc mật khẩu không đúng');
    }

    final token = JwtHelper.generateToken(user);
    final authResponse = AuthResponse(
      accessToken: token,
      expiresIn: JwtHelper.expiryInSeconds,
      user: user.toSafeMap(),
    );

    return ApiResponse.success(
      data: authResponse.toMap(),
      message: 'Đăng nhập thành công',
    );
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi đăng nhập: $e');
  }
}
