import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/sinh_vien_repository.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';

// API lấy danh sách sinh viên theo lớp chuyên ngành có điểm C <= 5
FutureOr<Response> onRequest(RequestContext context) async {
  try {

    final lop = context.request.uri.queryParameters['lop'];

    if (lop == null || lop.isEmpty) {
      return ApiResponse.validationError(
        message: 'Thiếu tham số lớp chuyên ngành',
        errors: {'lop': 'Vui lòng truyền ?lop=...'},
      );
    }

    final repo = SinhVienRepository();

   
    final list = await repo.getSinhVienDiemCThapTheoLop(
      lop: lop,
      maxC: 5,
    );

    return ApiResponse.success(
      data: list,
      message: 'Danh sách sinh viên lớp $lop có điểm C <= 5',
    );
  } catch (e) {
    return ApiResponse.error(message: e.toString());
  }
}
