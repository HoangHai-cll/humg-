import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/weather_widget.dart';
import 'admin/sinh_vien_list_screen.dart';
import 'admin/hoc_phan_list_screen.dart';
import 'admin/lop_list_screen.dart';
import 'admin/khoa_list_screen.dart';
import 'admin/user_list_screen.dart';
import 'admin/diem_management_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  Future<void> _handleLogout() async {
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

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().loadDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const WeatherWidget(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '👑 Admin Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Cards
                    Consumer<AdminProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoadingDashboard) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final stats = provider.dashboardStats;
                        if (stats == null) {
                          return const Center(
                            child: Text('Không thể tải thống kê'),
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    '🎓 Sinh viên',
                                    '${stats['tong_sinh_vien'] ?? 0}',
                                    const Color(0xFF2196F3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    '📚 Học phần',
                                    '${stats['tong_hoc_phan'] ?? 0}',
                                    const Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    '🏫 Lớp',
                                    '${stats['tong_lop'] ?? 0}',
                                    const Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    '🏛️ Khoa',
                                    '${stats['tong_khoa'] ?? 0}',
                                    const Color(0xFF9C27B0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildStatCard(
                              '👥 Tài khoản',
                              '${stats['tong_tai_khoan'] ?? 0}',
                              const Color(0xFF607D8B),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Menu Grid
                    const Text(
                      'Quản lý',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                          icon: Icons.people,
                          title: 'Sinh viên',
                          color: const Color(0xFF2196F3),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SinhVienListScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.book,
                          title: 'Học phần',
                          color: const Color(0xFF4CAF50),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HocPhanListScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.class_,
                          title: 'Lớp',
                          color: const Color(0xFFFF9800),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LopListScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.account_balance,
                          title: 'Khoa',
                          color: const Color(0xFF9C27B0),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KhoaListScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.grade,
                          title: 'Điểm',
                          color: const Color(0xFFE91E63),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DiemManagementScreen(),
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          icon: Icons.admin_panel_settings,
                          title: 'Tài khoản',
                          color: const Color(0xFF607D8B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserListScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
