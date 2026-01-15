import 'dart:async';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/sinh_vien_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
import 'package:quanlydaotao_api_backend/utils/jwt_helper.dart';

FutureOr<Response> onRequest(RequestContext context, String makhoa) async {
  final authHeader = context.request.headers['authorization'];

  return switch (context.request.method) {
    HttpMethod.get => await _lietkeSinhvien(context, makhoa, authHeader),
    _ => ApiResponse.error(message: 'Method not allowed', statusCode: 405),
  };
}

/// GET(admin) /api/v1/danhsachsinhvien/:makhoa - Liệt kê sinh viên theo mã khoa
Future<Response> _lietkeSinhvien(
  RequestContext context,
  String makhoa,
  String? authHeader,
) async {
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.unauthorized();
  }

  final token = authHeader.substring(7);
  if (!JwtHelper.isAdmin(token)) {
    return ApiResponse.forbidden(
        message: 'Chỉ admin mới có quyền xem thống kê');
  }

  try {
    final svRepo = SinhVienRepository();
    List<Map<String, dynamic>> dssv = svRepo.findByKhoa(makhoa)
        .map((sv) => sv.toMap())
        .toList();

    return ApiResponse.success(data: jsonEncode(dssv));
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi lấy danh sách sinh viên: $e');
  }
}
