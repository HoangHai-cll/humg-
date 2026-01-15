import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/models/diem_hoc_phan.dart';
import 'package:quanlydaotao_api_backend/repositories/diem_hoc_phan_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
import 'package:quanlydaotao_api_backend/utils/jwt_helper.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  final authHeader = context.request.headers['authorization'];

  return switch (context.request.method) {
    HttpMethod.get => context.request.uri.queryParameters.containsKey('mhp')
        ? await _getDiemHocPhan(context, authHeader)
        : await _getBangDiem(context, authHeader),
    HttpMethod.post => await _upsertDiem(context, authHeader),
    _ => ApiResponse.error(message: 'Method not allowed', statusCode: 405),
  };
}

/// GET /api/v1/diem?msv=xxx - Lấy bảng điểm sinh viên
Future<Response> _getBangDiem(
    RequestContext context, String? authHeader,) async {
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.unauthorized();
  }

  final token = authHeader.substring(7);
  final payload = JwtHelper.verifyToken(token);
  if (payload == null) {
    return ApiResponse.unauthorized(message: 'Token không hợp lệ');
  }

  final params = context.request.uri.queryParameters;
  var msv = params['msv'];
  final isAdmin = JwtHelper.isAdmin(token);
  final currentMsv = JwtHelper.getMsvFromToken(token);

  // Nếu không truyền MSV, lấy bảng điểm của chính mình
  msv ??= currentMsv;

  // Kiểm tra quyền
  if (!isAdmin && msv != currentMsv) {
    return ApiResponse.forbidden(
      message: 'Bạn không có quyền xem bảng điểm của sinh viên khác',
    );
  }

  if (msv == null) {
    return ApiResponse.error(message: 'Vui lòng cung cấp mã sinh viên');
  }

  try {
    final diemRepo = DiemHocPhanRepository();
    final bangDiem = diemRepo.getBangDiem(msv);
    final dtbTichLuy = diemRepo.tinhDTBTichLuy(msv);

    return ApiResponse.success(data: {
      'msv': msv,
      'diem_hoc_phan': bangDiem,
      'tong_ket': dtbTichLuy,
    },);
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi lấy bảng điểm: $e');
  }
}

/// POST /api/v1/diem - Thêm/cập nhật điểm (chỉ admin)
Future<Response> _upsertDiem(RequestContext context, String? authHeader) async {
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.unauthorized();
  }

  final token = authHeader.substring(7);
  if (!JwtHelper.isAdmin(token)) {
    return ApiResponse.forbidden(message: 'Chỉ admin mới có quyền nhập điểm');
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Validate
    final errors = <String, String>{};

    final msv = body['msv'] as String?;
    final mahocphan = body['mahocphan'] as String?;

    if (msv == null || msv.isEmpty) errors['msv'] = 'Mã sinh viên là bắt buộc';
    if (mahocphan == null || mahocphan.isEmpty) {
      errors['mahocphan'] = 'Mã học phần là bắt buộc';
    }

    if (errors.isNotEmpty) {
      return ApiResponse.validationError(errors: errors);
    }

    final diem = DiemHocPhan(
      msv: msv!,
      mahocphan: mahocphan!,
      diemA: (body['diem_a'] as num?)?.toDouble(),
      diemB: (body['diem_b'] as num?)?.toDouble(),
      diemC: (body['diem_c'] as num?)?.toDouble(),
    );

    final diemRepo = DiemHocPhanRepository();
    final saved = diemRepo.upsert(diem);

    if (saved == null) {
      return ApiResponse.serverError(message: 'Không thể lưu điểm');
    }

    return ApiResponse.success(
      data: saved.toMapWithCalculated(),
      message: 'Lưu điểm thành công',
    );
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi lưu điểm: $e');
  }
}

/// GET /api/v1/diem?msv=xxx&mhp=xxx - Lấy điểm cụ thể của sinh viên
Future<Response> _getDiemHocPhan(RequestContext context, String? authHeader,) async {
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return ApiResponse.unauthorized();
  }

  final token = authHeader.substring(7);
  final payload = JwtHelper.verifyToken(token);
  if (payload == null) {
    return ApiResponse.unauthorized(message: 'Token không hợp lệ');
  }

  final params = context.request.uri.queryParameters;
  var msv = params['msv'];
  var mhp = params['mhp'];

  final isAdmin = JwtHelper.isAdmin(token);
  final currentMsv = JwtHelper.getMsvFromToken(token);

  // Nếu không truyền MSV, lấy bảng điểm của chính mình
  msv ??= currentMsv;

  // Kiểm tra quyền
  if (!isAdmin && msv != currentMsv) {
    return ApiResponse.forbidden(
      message: 'Bạn không có quyền xem bảng điểm của sinh viên khác',
    );
  }

  if (msv == null) {
    return ApiResponse.error(message: 'Vui lòng cung cấp mã sinh viên');
  }

  try {
    final diemRepo = DiemHocPhanRepository();
    final diemHocPhan = diemRepo.findOne(msv, mhp!);

    return ApiResponse.success(
      data: {
        'msv': msv,
        'diem_hoc_phan': diemHocPhan,
      },
    );
  } catch (e) {
    return ApiResponse.serverError(message: 'Lỗi lấy điểm học phần: $e');
  }
}