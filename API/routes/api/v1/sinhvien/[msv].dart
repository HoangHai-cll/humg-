import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/repositories.dart';
import 'package:quanlydaotao_api_backend/utils/api_response.dart';

// api xem thong tin sinh vien theo msv
FutureOr<Response> onRequest(
  RequestContext context,
  String msv,
) async {
  if (msv.trim().isEmpty) {
    return ApiResponse.error(
      message: 'Thiếu mã sinh viên',
      statusCode: 400,
    );
  }

  final svRepo = SinhVienRepository();
  final detail = await svRepo.findDetailByMsv(msv);

  if (detail == null) {
    return ApiResponse.notFound(
      message: 'Không tìm thấy sinh viên',
    );
  }

  // Lấy danh sách điểm của sinh viên
  final diemRepo = DiemHocPhanRepository();
  final diemList = diemRepo.findByMsv(msv);
  double diemTong = 0;
  int diemCount = 0;
  for (final diem in diemList) {
    final diemA = diem.diemA ?? 0.0;
    final diemB = diem.diemB ?? 0.0;
    final diemC = diem.diemC ?? 0.0;
    final diemTb = (diemA + diemB + diemC) / 3.0;
    diemTong += diemTb;
    diemCount++;
  }
  double diemTrungBinh = diemCount > 0 ? diemTong / diemCount : 0.0;
  String hocLuc;
  if (diemTrungBinh >= 8.0) {
    hocLuc = 'Giỏi';
  } else if (diemTrungBinh >= 6.5) {
    hocLuc = 'Khá';
  } else if (diemTrungBinh >= 5.0) {
    hocLuc = 'Trung bình';
  } else {
    hocLuc = 'Yếu';
  }

  final data = {
    'sinh_vien': {
      'msv': detail['msv'],
      'ho_va_ten': '${detail['hodem']} ${detail['ten']}',
      'ngay_sinh': detail['ngaysinh'],
      'gioi_tinh': detail['gioitinh'],
      'ma_lop': detail['malop'],
      'hoc_luc': hocLuc,
    },
    'lop': {
      'ma_lop': detail['malop'],
      'ten_lop': detail['tenlop'],
      'he_dao_tao': detail['hedaotao'],
      'nien_khoa': detail['nienkhoa'],
      'ten_khoa': detail['tenkhoa'],
    }
  };

  return ApiResponse.success(data: data);
}
