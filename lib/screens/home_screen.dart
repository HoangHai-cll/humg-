import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/weather_widget.dart';
import '../services/admin_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'hocphan_list_screen.dart';
import 'ket_qua_hoc_tap_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdminService _adminService = AdminService();

  // Dữ liệu tổng quan học tập
  double? _dtbHe10;
  int _tongTinChi = 0;
  int _tinChiDat = 0;
  String _xepLoai = '--';
  int _soMonHoc = 0;
  bool _isLoadingTongQuan = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTongQuanHocTap();
    });
  }

  Future<void> _loadTongQuanHocTap() async {
    try {
      final user = context.read<AuthProvider>().user;
      final msv = user?.msv;

      if (msv == null || msv.isEmpty) {
        setState(() => _isLoadingTongQuan = false);
        return;
      }

      final res = await _adminService.getBangDiem(msv);

      if (res['success'] == true && mounted) {
        final data = res['data'];
        final tongKet = data['tong_ket'] as Map<String, dynamic>?;
        final diemHocPhans = data['diem_hoc_phan'] as List<dynamic>? ?? [];

        final dtb = (tongKet?['dtb_he_10'] as num?)?.toDouble();

        setState(() {
          _dtbHe10 = dtb;
          _tongTinChi = tongKet?['tong_tin_chi'] ?? 0;
          _tinChiDat = tongKet?['tin_chi_dat'] ?? 0;
          _soMonHoc = diemHocPhans.length;
          _xepLoai = _getXepLoai(dtb);
          _isLoadingTongQuan = false;
        });
      } else {
        setState(() => _isLoadingTongQuan = false);
      }
    } catch (e) {
      setState(() => _isLoadingTongQuan = false);
    }
  }

  String _getXepLoai(double? dtb) {
    if (dtb == null) return '--';
    if (dtb >= 9.0) return 'Xuất sắc';
    if (dtb >= 8.0) return 'Giỏi';
    if (dtb >= 7.0) return 'Khá';
    if (dtb >= 5.5) return 'TB';
    if (dtb >= 4.0) return 'Yếu';
    return 'Kém';
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng Xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng Xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Weather Widget
            const WeatherWidget(),

            // User Info & Menu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF2196F3),
                          child: Text(
                            user?.email.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                user?.hoTen ?? user?.email ?? 'Người dùng',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (user?.msv != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${user!.msv}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () => _handleLogout(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tổng quan học tập
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7B68EE), Color(0xFF9370DB)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_graph,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tổng quan học tập',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _isLoadingTongQuan
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildTongQuanItem(
                                    value: _dtbHe10?.toStringAsFixed(1) ?? '--',
                                    label: 'Điểm TB',
                                  ),
                                  _buildTongQuanItem(
                                    value: '$_tinChiDat/$_tongTinChi',
                                    label: 'Tín chỉ',
                                  ),
                                  _buildTongQuanItem(
                                    value: _xepLoai,
                                    label: 'Xếp loại',
                                  ),
                                  _buildTongQuanItem(
                                    value: _soMonHoc.toString(),
                                    label: 'Môn học',
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chức năng title
                  const Text(
                    'Chức năng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildMenuItem(
                        icon: Icons.person,
                        title: 'Thông tin\ncá nhân',
                        color: const Color(0xFF2196F3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.school,
                        title: 'Kết quả\nhọc tập',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KetQuaHocTapScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.menu_book,
                        title: 'Danh sách\nhọc phần',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HocPhanListScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Đăng xuất',
                        color: const Color(0xFFE53935),
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTongQuanItem({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
