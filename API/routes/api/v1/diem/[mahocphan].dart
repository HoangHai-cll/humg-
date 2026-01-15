import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/diem_hoc_phan_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
import 'package:quanlydaotao_api_backend/utils/jwt_helper.dart';

FutureOr<Response> onRequest(RequestContext context, String mahocphan) async {
  final authHeader = context.request.headers['authorization'];

  return switch (context.request.method) {
    HttpMethod.get => await _getThongKe(context, mahocphan, authHeader),
    HttpMethod.delete => await _deleteDiem(context, mahocphan, authHeader),
    _ => ApiResponse.error(message: 'Method not allowed', statusCode: 405),
  };
}

/// GET /api/v1/diem/:mahocphan - Lấy thống kê điểm học phần (admin)
Future<Response> _getThongKe(
  RequestContext context,
  String mahocphan,
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
    final params = context.request.uri.queryParameters;
    final malop = params['malop'];

    final diemRepo = DiemHocPhanRepository();

    final result = <String, dynamic>{
      'mahocphan': mahocphan,
      'thong_ke': diemRepo.thongKeDiem(mahocphan),
    };

    if (malop != null) {
      result['diem_lop'] = diemRepo.getDiemLop(malop, mahocphan);
    }

    return ApiResponse.success(data: result);
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi lấy thống kê: $e');
  }
}

/// DELETE /api/v1/diem/:mahocphan?msv=xxx - Xóa điểm (admin)
Future<Response> _deleteDiem(
  RequestContext context,
  String mahocphan,
  String? authHeader,
) async {
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.unauthorized();
  }

  final token = authHeader.substring(7);
  if (!JwtHelper.isAdmin(token)) {
    return ApiResponse.forbidden(message: 'Chỉ admin mới có quyền xóa điểm');
  }

  final msv = context.request.uri.queryParameters['msv'];
  if (msv == null) {
    return ApiResponse.error(message: 'Vui lòng cung cấp mã sinh viên');
  }

  try {
    final diemRepo = DiemHocPhanRepository();
    final deleted = diemRepo.delete(msv, mahocphan);

    if (!deleted) {
      return ApiResponse.notFound(message: 'Không tìm thấy điểm');
    }

    return ApiResponse.success(message: 'Xóa điểm thành công');
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi xóa điểm: $e');
  }
}
