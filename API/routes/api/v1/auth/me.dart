import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/auth_repository.dart';
import 'package:quanlydaotao_api_backend/repositories/sinh_vien_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
import 'package:quanlydaotao_api_backend/utils/jwt_helper.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  // Xác thực token
  final authHeader = context.request.headers['authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.unauthorized(message: 'Token không được cung cấp');
  }

  return switch (context.request.method) {
    HttpMethod.get => await _getMe(context),
    _ => ApiResponse.error(message: 'Method not allowed', statusCode: 405),
  };
}

Future<Response> _getMe(RequestContext context) async {
  try {
    final authHeader = context.request.headers['authorization']!;
    final token = authHeader.substring(7);

    final payload = _verifyToken(token);
    if (payload == null) {
      return ApiResponse.unauthorized(message: 'Token không hợp lệ');
    }

    final userId = int.tryParse(payload['sub'] as String? ?? '');
    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Token không hợp lệ');
    }

    final authRepo = AuthRepository();
    final user = authRepo.findById(userId);
    if (user == null) {
      return ApiResponse.notFound(message: 'Người dùng không tồn tại');
    }

    final result = <String, dynamic>{
      ...user.toSafeMap(),
    };

    // Nếu là sinh viên, thêm thông tin sinh viên
    if (user.msv != null) {
      final svRepo = SinhVienRepository();
      final svDetail = svRepo.findDetailByMsv(user.msv!);
      if (svDetail != null) {
        result['sinh_vien'] = svDetail;
      }
    }

    return ApiResponse.success(data: result);
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi lấy thông tin: $e');
  }
}

Map<String, dynamic>? _verifyToken(String token) {
  return JwtHelper.verifyToken(token);
}
