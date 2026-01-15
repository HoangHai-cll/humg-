import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/sinh_vien_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';
// 1. API lấy danh sách sinh viên có điểm a >= 8

FutureOr<Response> onRequest(RequestContext context) async {
  try {
    final repo = SinhVienRepository();
    final list = repo.getSinhVienDiemA(8);

    return ApiResponse.success(
      data: list,
      message: 'Danh sách sinh viên có điểm A >= 8',
    );
  } catch (e) {
    return ApiResponse.error(message: e.toString());
  }
}
