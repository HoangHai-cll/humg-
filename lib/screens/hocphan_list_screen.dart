import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/admin_service.dart';

class HocPhanListScreen extends StatefulWidget {
  const HocPhanListScreen({Key? key}) : super(key: key);

  @override
  State<HocPhanListScreen> createState() => _HocPhanListScreenState();
}

class _HocPhanListScreenState extends State<HocPhanListScreen> {
  final AdminService _adminService = AdminService();

  int _currentPage = 1;
  final int _perPage = 20;

  bool _isLoading = true;
  String? _error;
  List<dynamic> _hocPhans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHocPhans();
    });
  }

  Future<void> _fetchHocPhans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = context.read<AuthProvider>().user;
      final msv = user?.msv;

      if (msv == null || msv.isEmpty) {
        setState(() {
          _error = 'Không tìm thấy mã sinh viên';
          _isLoading = false;
        });
        return;
      }

      final res = await _adminService.getHocPhanChiTietByMsv(
        msv: msv,
        page: _currentPage,
        perPage: _perPage,
      );

      if (res['success'] == true) {
        setState(() {
          _hocPhans = res['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['message'] ?? 'Không lấy được học phần';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Học phần đã đăng ký')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
              itemCount: _hocPhans.length,
              itemBuilder: (context, index) {
                final hp = _hocPhans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(
                      hp['tenhocphan'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã học phần: ${hp['mahocphan']}'),
                        Text('Số tín chỉ: ${hp['tinchi']}'),
                        Text('Học kỳ: ${hp['hocky']}'),
                        Text('Năm học: ${hp['namhoc']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
