
// lib/providers/admin_provider.dart
import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
final AdminService _adminService;

// Dashboard
Map<String, dynamic>? _dashboardStats;
bool _isLoadingDashboard = false;

// Sinh viên
List<dynamic> _sinhViens = [];
Map<String, dynamic>? _sinhVienPagination;
bool _isLoadingSinhVien = false;

// Học phần
List<dynamic> _hocPhans = [];
Map<String, dynamic>? _hocPhanPagination;
bool _isLoadingHocPhan = false;

// Lớp
List<dynamic> _lops = [];
Map<String, dynamic>? _lopPagination;
bool _isLoadingLop = false;

// Khoa
List<dynamic> _khoas = [];
Map<String, dynamic>? _khoaPagination;
bool _isLoadingKhoa = false;

// Users
List<dynamic> _users = [];
Map<String, dynamic>? _userPagination;
bool _isLoadingUser = false;

// Error
String? _errorMessage;

AdminProvider({AdminService? adminService})
    : _adminService = adminService ?? AdminService();

// Getters
Map<String, dynamic>? get dashboardStats => _dashboardStats;
bool get isLoadingDashboard => _isLoadingDashboard;

List<dynamic> get sinhViens => _sinhViens;
Map<String, dynamic>? get sinhVienPagination => _sinhVienPagination;
bool get isLoadingSinhVien => _isLoadingSinhVien;

List<dynamic> get hocPhans => _hocPhans;
Map<String, dynamic>? get hocPhanPagination => _hocPhanPagination;
bool get isLoadingHocPhan => _isLoadingHocPhan;

List<dynamic> get lops => _lops;
Map<String, dynamic>? get lopPagination => _lopPagination;
bool get isLoadingLop => _isLoadingLop;

List<dynamic> get khoas => _khoas;
Map<String, dynamic>? get khoaPagination => _khoaPagination;
bool get isLoadingKhoa => _isLoadingKhoa;

List<dynamic> get users => _users;
Map<String, dynamic>? get userPagination => _userPagination;
bool get isLoadingUser => _isLoadingUser;

String? get errorMessage => _errorMessage;

// ==================== DASHBOARD ====================

Future<void> loadDashboard() async {
_isLoadingDashboard = true;
_errorMessage = null;
notifyListeners();

final result = await _adminService.getDashboard();

if (result['success'] == true) {
_dashboardStats = result['data'];
} else {
_errorMessage = result['message'];
}

_isLoadingDashboard = false;
notifyListeners();
}

// ==================== SINH VIÊN ====================

Future<void> loadSinhViens({
int page = 1,
int perPage = 20,
String? malop,
String? search,
}) async {
_isLoadingSinhVien = true;
_errorMessage = null;
notifyListeners();

final result = await _adminService.getSinhViens(
page: page,
perPage: perPage,
malop: malop,
search: search,
);

if (result['success'] == true) {
_sinhViens = result['data'] ?? [];
_sinhVienPagination = result['pagination'];
} else {
_errorMessage = result['message'];
}

_isLoadingSinhVien = false;
notifyListeners();
}

Future<Map<String, dynamic>> createSinhVien({
required String msv,
required String hodem,
required String ten,
required String ngaysinh,
required String gioitinh,
required String malop,
}) async {
final result = await _adminService.createSinhVien(
msv: msv,
hodem: hodem,
ten: ten,
ngaysinh: ngaysinh,
gioitinh: gioitinh,
malop: malop,
);

if (result['success'] == true) {
await loadSinhViens(); // Refresh list
}

return result;
}

Future<Map<String, dynamic>> updateSinhVien(
String msv,
Map<String, dynamic> updateData,
) async {
final result = await _adminService.updateSinhVien(msv, updateData);

if (result['success'] == true) {
await loadSinhViens(); // Refresh list
}

return result;
}

Future<Map<String, dynamic>> deleteSinhVien(String msv) async {
final result = await _adminService.deleteSinhVien(msv);

if (result['success'] == true) {
await loadSinhViens(); // Refresh list
}

return result;
}

// ==================== HỌC PHẦN ====================

Future<void> loadHocPhans({
int page = 1,
int perPage = 20,
String? search,
}) async {
_isLoadingHocPhan = true;
_errorMessage = null;
notifyListeners();

final result = await _adminService.getHocPhans(
page: page,
perPage: perPage,
search: search,
);

if (result['success'] == true) {
_hocPhans = result['data'] ?? [];
_hocPhanPagination = result['pagination'];
} else {
_errorMessage = result['message'];
}

_isLoadingHocPhan = false;
notifyListeners();
}

Future<Map<String, dynamic>> createHocPhan({
required String mahocphan,
required String tenhocphan,
required int tinchi,
}) async {
final result = await _adminService.createHocPhan(
mahocphan: mahocphan,
tenhocphan: tenhocphan,
tinchi: tinchi,
);

if (result['success'] == true) {
await loadHocPhans();
}

return result;
}

Future<Map<String, dynamic>> updateHocPhan(
String mahocphan,
Map<String, dynamic> updateData,
) async {
final result = await _adminService.updateHocPhan(mahocphan, updateData);

if (result['success'] == true) {
await loadHocPhans();
}

return result;
}

Future<Map<String, dynamic>> deleteHocPhan(String mahocphan) async {
final result = await _adminService.deleteHocPhan(mahocphan);

if (result['success'] == true) {
await loadHocPhans();
}

return result;
}

// ==================== ĐIỂM ====================

Future<Map<String, dynamic>> getBangDiem(String msv) async {
return await _adminService.getBangDiem(msv);
}

Future<Map<String, dynamic>> upsertDiem({
required String msv,
required String mahocphan,
double? diemA,
double? diemB,
double? diemC,
}) async {
return await _adminService.upsertDiem(
msv: msv,
mahocphan: mahocphan,
diemA: diemA,
diemB: diemB,
diemC: diemC,
);
}

Future<Map<String, dynamic>> getThongKeDiem(
String mahocphan, {
String? malop,
}) async {
return await _adminService.getThongKeDiem(mahocphan, malop: malop);
}

// ==================== LỚP ====================

Future<void> loadLops({
int page = 1,
int perPage = 20,
String? makhoa,
}) async {
_isLoadingLop = true;
_errorMessage = null;
notifyListeners();

final result = await _adminService.getLops(
page: page,
perPage: perPage,
makhoa: makhoa,
);

if (result['success'] == true) {
_lops = result['data'] ?? [];
_lopPagination = result['pagination'];
} else {
_errorMessage = result['message'];
}

_isLoadingLop = false;
notifyListeners();
}

Future<Map<String, dynamic>> createLop({
required String malop,
required String tenlop,
required String hedaotao,
required String nienkhoa,
required String makhoa,
}) async {
final result = await _adminService.createLop(
malop: malop,
tenlop: tenlop,
hedaotao: hedaotao,
nienkhoa: nienkhoa,
makhoa: makhoa,
);

if (result['success'] == true) {
await loadLops();
}

return result;
}

Future<Map<String, dynamic>> updateLop(
String malop,
Map<String, dynamic> updateData,
) async {
final result = await _adminService.updateLop(malop, updateData);

if (result['success'] == true) {
await loadLops();
}

return result;
}

Future<Map<String, dynamic>> deleteLop(String malop) async {
final result = await _adminService.deleteLop(malop);

if (result['success'] == true) {
await loadLops();
}

return result;
}

// ==================== KHOA ====================

Future<void> loadKhoas({int page = 1, int perPage = 20}) async {
_isLoadingKhoa = true;
_errorMessage = null;
notifyListeners();

final result = await _adminService.getKhoas(page: page, perPage: perPage);

if (result['success'] == true) {
_khoas = result['data'] ?? [];
_khoaPagination = result['pagination'];
} else {
_errorMessage = result['message'];
}

_isLoadingKhoa = false;
notifyListeners();
}

Future<Map<String, dynamic>> createKhoa({
required String makhoa,
required String tenkhoa,
String? sdt,
String? email,
String? website,
}) async {
final result = await _adminService.createKhoa(
makhoa: makhoa,
tenkhoa: tenkhoa,
sdt: sdt,
email: email,
website: website,
);

if (result['success'] == true) {
await loadKhoas();
}

return result;
}

Future<Map<String, dynamic>> updateKhoa(
String makhoa,
Map<String, dynamic> updateData,
) async {
final result = await _adminService.updateKhoa(makhoa, updateData);

if (result['success'] == true) {
await loadKhoas();
}

return result;
}

Future<Map<String, dynamic>> deleteKhoa(String makhoa) async {
final result = await _adminService.deleteKhoa(makhoa);

if (result['success'] == true) {
await loadKhoas();
}

return result;
}

// ==================== USERS ====================

Future<void> loadUsers({int page = 1, int perPage = 20}) async {
_isLoadingUser = true;
_errorMessage = null;
notifyListeners();

final result = await _adminService.getUsers(page: page, perPage: perPage);

if (result['success'] == true) {
_users = result['data'] ?? [];
_userPagination = result['pagination'];
} else {
_errorMessage = result['message'];
}

_isLoadingUser = false;
notifyListeners();
}

Future<Map<String, dynamic>> createAdmin({
required String email,
required String password,
String role = 'admin',
}) async {
final result = await _adminService.createAdmin(
email: email,
password: password,
role: role,
);

if (result['success'] == true) {
await loadUsers();
}

return result;
}

// Clear error
void clearError() {
_errorMessage = null;
notifyListeners();
}
}
