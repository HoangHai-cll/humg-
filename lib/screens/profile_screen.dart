import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/admin_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân')),
      body: user == null
          ? const Center(child: Text('Không có thông tin người dùng'))
          : FutureBuilder<Map<String, dynamic>>(
              future: _fetchProfile(user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!['student'] == null) {
                  return const Center(
                    child: Text('Không tìm thấy thông tin sinh viên'),
                  );
                }

                final student = snapshot.data!['student'];
                final classInfo = snapshot.data!['class'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(student, user),
                      _buildStudentInfo(student),
                      if (classInfo != null) _buildClassInfo(classInfo),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<Map<String, dynamic>> _fetchProfile(user) async {
    final adminService = AdminService();
    final msv = user.msv;

    if (msv == null) {
      return {'student': null, 'class': null};
    }

    final res = await adminService.getSinhVienDetail(msv);
    if (res['success'] != true) {
      return {'student': null, 'class': null};
    }

    return {'student': res['data']['sinh_vien'], 'class': res['data']['lop']};
  }

  Widget _buildHeader(Map<String, dynamic> student, user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              (student['ho_va_ten'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student['ho_va_ten'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'MSV: ${student['msv'] ?? user.msv}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(Map<String, dynamic> student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleRow(Icons.person, 'Thông tin sinh viên'),
            _infoRow('Mã sinh viên', student['msv']),
            _infoRow('Họ và tên', student['ho_va_ten']),
            _infoRow('Ngày sinh', student['ngay_sinh']),
            _infoRow('Giới tính', student['gioi_tinh']),
            _infoRow('Mã lớp', student['ma_lop']),
            _infoRow('Học lực', student['hoc_luc']),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfo(Map<String, dynamic> classInfo) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleRow(Icons.class_, 'Thông tin lớp'),
            _infoRow('Mã lớp', classInfo['ma_lop']),
            _infoRow('Tên lớp', classInfo['ten_lop']),
            _infoRow('Hệ đào tạo', classInfo['he_dao_tao']),
            _infoRow('Niên khóa', classInfo['nien_khoa']),
            _infoRow('Khoa', classInfo['ten_khoa']),
          ],
        ),
      ),
    );
  }

  Widget _titleRow(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
