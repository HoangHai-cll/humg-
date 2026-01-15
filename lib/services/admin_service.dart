/*
 * Admin Service - Quản lý các chức năng dành cho admin (gọi các API admin)
 * Bao gồm quản lý sinh viên, học phần, điểm, lớp, khoa và users
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_service.dart';

class AdminService {
  final String baseUrl;
  final AuthService _authService;

  AdminService({this.baseUrl = AppConstants.baseUrl, AuthService? authService})
    : _authService = authService ?? AuthService();

  /// Lấy headers với token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ==================== DASHBOARD ====================

  /// Lấy thống kê dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    final url = Uri.parse('$baseUrl/admin/dashboard');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy thống kê',
      };
    }
  }

  // ==================== QUẢN LÝ SINH VIÊN ====================

  /// Lấy danh sách sinh viên
  Future<Map<String, dynamic>> getSinhViens({
    int page = 1,
    int perPage = 20,
    String? malop,
    String? search,
  }) async {
    var url = '$baseUrl/sinhvien?page=$page&per_page=$perPage';
    if (malop != null) url += '&malop=$malop';
    if (search != null && search.isNotEmpty) url += '&search=$search';

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'data': data['data'],
        'pagination': data['pagination'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy danh sách sinh viên',
      };
    }
  }

  /// Lấy chi tiết sinh viên
  Future<Map<String, dynamic>> getSinhVienDetail(String msv) async {
    final url = Uri.parse('$baseUrl/sinhvien/$msv');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Không tìm thấy sinh viên',
      };
    }
  }

  /// Thêm sinh viên mới
  Future<Map<String, dynamic>> createSinhVien({
    required String msv,
    required String hodem,
    required String ten,
    required String ngaysinh,
    required String gioitinh,
    required String malop,
  }) async {
    final url = Uri.parse('$baseUrl/sinhvien');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'msv': msv,
        'hodem': hodem,
        'ten': ten,
        'ngaysinh': ngaysinh,
        'gioitinh': gioitinh,
        'malop': malop,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi thêm sinh viên',
        'errors': data['errors'],
      };
    }
  }

  /// Cập nhật sinh viên
  Future<Map<String, dynamic>> updateSinhVien(
    String msv,
    Map<String, dynamic> updateData,
  ) async {
    final url = Uri.parse('$baseUrl/sinhvien/$msv');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(updateData),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi cập nhật sinh viên',
      };
    }
  }

  /// Xóa sinh viên
  Future<Map<String, dynamic>> deleteSinhVien(String msv) async {
    final url = Uri.parse('$baseUrl/sinhvien/$msv');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'message': 'Xóa sinh viên thành công'};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi xóa sinh viên',
      };
    }
  }

  // ==================== QUẢN LÝ HỌC PHẦN ====================

  /// Lấy danh sách học phần
  Future<Map<String, dynamic>> getHocPhans({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    var url = '$baseUrl/hocphan?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) url += '&search=$search';

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'data': data['data'],
        'pagination': data['pagination'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy danh sách học phần',
      };
    }
  }

  /// Thêm học phần mới
  Future<Map<String, dynamic>> createHocPhan({
    required String mahocphan,
    required String tenhocphan,
    required int tinchi,
  }) async {
    final url = Uri.parse('$baseUrl/hocphan');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'mahocphan': mahocphan,
        'tenhocphan': tenhocphan,
        'tinchi': tinchi,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi thêm học phần',
      };
    }
  }

  /// Cập nhật học phần
  Future<Map<String, dynamic>> updateHocPhan(
    String mahocphan,
    Map<String, dynamic> updateData,
  ) async {
    final url = Uri.parse('$baseUrl/hocphan/$mahocphan');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(updateData),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi cập nhật học phần',
      };
    }
  }

  /// Xóa học phần
  Future<Map<String, dynamic>> deleteHocPhan(String mahocphan) async {
    final url = Uri.parse('$baseUrl/hocphan/$mahocphan');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'message': 'Xóa học phần thành công'};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi xóa học phần',
      };
    }
  }

  // ==================== QUẢN LÝ ĐIỂM ====================

  /// Lấy bảng điểm sinh viên
  Future<Map<String, dynamic>> getBangDiem(String msv) async {
    final url = Uri.parse('$baseUrl/diem?msv=$msv');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy bảng điểm',
      };
    }
  }

  /// Nhập/Cập nhật điểm
  Future<Map<String, dynamic>> upsertDiem({
    required String msv,
    required String mahocphan,
    double? diemA,
    double? diemB,
    double? diemC,
  }) async {
    final url = Uri.parse('$baseUrl/diem');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'msv': msv,
        'mahocphan': mahocphan,
        'diem_a': diemA,
        'diem_b': diemB,
        'diem_c': diemC,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi lưu điểm'};
    }
  }

  /// Lấy thống kê điểm học phần
  Future<Map<String, dynamic>> getThongKeDiem(
    String mahocphan, {
    String? malop,
  }) async {
    var url = '$baseUrl/diem/$mahocphan';
    if (malop != null) url += '?malop=$malop';

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy thống kê',
      };
    }
  }

  /// Xóa điểm
  Future<Map<String, dynamic>> deleteDiem(String msv, String mahocphan) async {
    final url = Uri.parse('$baseUrl/diem/$mahocphan?msv=$msv');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'message': 'Xóa điểm thành công'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi xóa điểm'};
    }
  }

  // ==================== QUẢN LÝ LỚP ====================

  /// Lấy danh sách lớp
  Future<Map<String, dynamic>> getLops({
    int page = 1,
    int perPage = 20,
    String? makhoa,
  }) async {
    var url = '$baseUrl/lop?page=$page&per_page=$perPage';
    if (makhoa != null) url += '&makhoa=$makhoa';

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'data': data['data'],
        'pagination': data['pagination'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy danh sách lớp',
      };
    }
  }

  /// Lấy chi tiết lớp
  Future<Map<String, dynamic>> getLopDetail(
    String malop, {
    bool includeStudents = false,
    bool includeCourses = false,
  }) async {
    var url = '$baseUrl/lop/$malop?';
    if (includeStudents) url += 'include_students=true&';
    if (includeCourses) url += 'include_courses=true';

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Không tìm thấy lớp',
      };
    }
  }

  /// Thêm lớp mới
  Future<Map<String, dynamic>> createLop({
    required String malop,
    required String tenlop,
    required String hedaotao,
    required String nienkhoa,
    required String makhoa,
  }) async {
    final url = Uri.parse('$baseUrl/lop');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'malop': malop,
        'tenlop': tenlop,
        'hedaotao': hedaotao,
        'nienkhoa': nienkhoa,
        'makhoa': makhoa,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi thêm lớp'};
    }
  }

  /// Cập nhật lớp
  Future<Map<String, dynamic>> updateLop(
    String malop,
    Map<String, dynamic> updateData,
  ) async {
    final url = Uri.parse('$baseUrl/lop/$malop');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(updateData),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi cập nhật lớp',
      };
    }
  }

  /// Xóa lớp
  Future<Map<String, dynamic>> deleteLop(String malop) async {
    final url = Uri.parse('$baseUrl/lop/$malop');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'message': 'Xóa lớp thành công'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi xóa lớp'};
    }
  }

  // ==================== QUẢN LÝ KHOA ====================

  /// Lấy danh sách khoa
  Future<Map<String, dynamic>> getKhoas({
    int page = 1,
    int perPage = 20,
  }) async {
    final url = '$baseUrl/khoa?page=$page&per_page=$perPage';
    final headers = await _getHeaders();

    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'data': data['data'],
        'pagination': data['pagination'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy danh sách khoa',
      };
    }
  }

  /// Lấy chi tiết khoa (kèm thống kê)
  Future<Map<String, dynamic>> getKhoaDetail(
    String makhoa, {
    bool includeStats = false,
  }) async {
    var url = '$baseUrl/khoa/$makhoa';
    if (includeStats) url += '?include_stats=true';

    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Không tìm thấy khoa',
      };
    }
  }

  /// Thêm khoa mới
  Future<Map<String, dynamic>> createKhoa({
    required String makhoa,
    required String tenkhoa,
    String? sdt,
    String? email,
    String? website,
  }) async {
    final url = Uri.parse('$baseUrl/khoa');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'makhoa': makhoa,
        'tenkhoa': tenkhoa,
        'sdt': sdt,
        'email': email,
        'website': website,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi thêm khoa'};
    }
  }

  /// Cập nhật khoa
  Future<Map<String, dynamic>> updateKhoa(
    String makhoa,
    Map<String, dynamic> updateData,
  ) async {
    final url = Uri.parse('$baseUrl/khoa/$makhoa');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(updateData),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi cập nhật khoa',
      };
    }
  }

  /// Xóa khoa
  Future<Map<String, dynamic>> deleteKhoa(String makhoa) async {
    final url = Uri.parse('$baseUrl/khoa/$makhoa');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'message': 'Xóa khoa thành công'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi xóa khoa'};
    }
  }

  // ==================== QUẢN LÝ USERS ====================

  /// Lấy danh sách users
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    final url = '$baseUrl/admin/users?page=$page&per_page=$perPage';
    final headers = await _getHeaders();

    final response = await http.get(Uri.parse(url), headers: headers);
    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'success': true,
        'data': data['data'],
        'pagination': data['pagination'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi lấy danh sách users',
      };
    }
  }

  /// Tạo tài khoản admin
  Future<Map<String, dynamic>> createAdmin({

    required String email,
    required String password,
    String role = 'admin',
  }) async {
    final url = Uri.parse('$baseUrl/admin/users');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({'email': email, 'password': password, 'role': role}),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {'success': true, 'data': data['data']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Lỗi tạo tài khoản',
      };
    }
  }

// xewm hoc phan chi tiet theo msv
   Future<Map<String, dynamic>> getHocPhanChiTietByMsv({
    required String msv,
    required int page,
    required int perPage,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/hocphan/?msv=$msv&page=$page&per_page=$perPage',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Lỗi server (${response.statusCode})',
      };
    }
  }
}
