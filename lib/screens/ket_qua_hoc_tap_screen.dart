import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/admin_service.dart';
import '../widgets/weather_widget.dart';

class KetQuaHocTapScreen extends StatefulWidget {
  const KetQuaHocTapScreen({super.key});

  @override
  State<KetQuaHocTapScreen> createState() => _KetQuaHocTapScreenState();
}

class _KetQuaHocTapScreenState extends State<KetQuaHocTapScreen> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  String? _error;

  // Dữ liệu kết quả học tập
  double? _dtbHe10;
  double? _dtbHe4;
  int _tongTinChi = 0;
  int _tinChiDat = 0;
  int _soMonHoc = 0;
  List<Map<String, dynamic>> _diemHocPhans = [];

  // Thống kê điểm chữ
  Map<String, int> _thongKeDiemChu = {
    'A+': 0,
    'A': 0,
    'B+': 0,
    'B': 0,
    'C+': 0,
    'C': 0,
    'D+': 0,
    'D': 0,
    'F': 0,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchKetQuaHocTap();
    });
  }

  Future<void> _fetchKetQuaHocTap() async {
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

      final res = await _adminService.getBangDiem(msv);

      if (res['success'] == true) {
        final data = res['data'];
        final tongKet = data['tong_ket'] as Map<String, dynamic>?;
        final diemHocPhans = (data['diem_hoc_phan'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        // Tính thống kê điểm chữ
        final thongKe = <String, int>{
          'A+': 0,
          'A': 0,
          'B+': 0,
          'B': 0,
          'C+': 0,
          'C': 0,
          'D+': 0,
          'D': 0,
          'F': 0,
        };

        for (final hp in diemHocPhans) {
          final diemChu = hp['diem_chu'] as String?;
          if (diemChu != null && thongKe.containsKey(diemChu)) {
            thongKe[diemChu] = thongKe[diemChu]! + 1;
          }
        }

        setState(() {
          _dtbHe10 = (tongKet?['dtb_he_10'] as num?)?.toDouble();
          _dtbHe4 = (tongKet?['dtb_he_4'] as num?)?.toDouble();
          _tongTinChi = tongKet?['tong_tin_chi'] ?? 0;
          _tinChiDat = tongKet?['tin_chi_dat'] ?? 0;
          _soMonHoc = diemHocPhans.length;
          _diemHocPhans = diemHocPhans;
          _thongKeDiemChu = thongKe;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['message'] ?? 'Không lấy được kết quả học tập';
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

  String _getXepLoai(double? dtb) {
    if (dtb == null) return 'Chưa xếp loại';
    if (dtb >= 9.0) return 'Xuất sắc';
    if (dtb >= 8.0) return 'Giỏi';
    if (dtb >= 7.0) return 'Khá';
    if (dtb >= 5.5) return 'Trung bình';
    if (dtb >= 4.0) return 'Yếu';
    return 'Kém';
  }

  Color _getXepLoaiColor(double? dtb) {
    if (dtb == null) return Colors.grey;
    if (dtb >= 9.0) return Colors.purple;
    if (dtb >= 8.0) return Colors.green;
    if (dtb >= 7.0) return Colors.blue;
    if (dtb >= 5.5) return Colors.orange;
    return Colors.red;
  }

  Color _getDiemChuColor(String diemChu) {
    switch (diemChu) {
      case 'A+':
        return const Color(0xFF9C27B0); // Purple
      case 'A':
        return const Color(0xFF4CAF50); // Green
      case 'B+':
        return const Color(0xFF2196F3); // Blue
      case 'B':
        return const Color(0xFF03A9F4); // Light Blue
      case 'C+':
        return const Color(0xFFFF9800); // Orange
      case 'C':
        return const Color(0xFFFFC107); // Amber
      case 'D+':
        return const Color(0xFFFF5722); // Deep Orange
      case 'D':
        return const Color(0xFFE91E63); // Pink
      case 'F':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchKetQuaHocTap,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Weather Widget with back button and title
          Stack(
            children: [
              const WeatherWidget(),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Kết quả học tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card điểm trung bình tích lũy
                _buildDTBCard(),
                const SizedBox(height: 16),

                // Thống kê nhanh
                _buildThongKeNhanh(),
                const SizedBox(height: 20),

                // Thống kê điểm chữ
                _buildThongKeDiemChu(),
                const SizedBox(height: 20),

                // Chi tiết điểm học phần
                _buildChiTietDiem(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDTBCard() {
    final xepLoai = _getXepLoai(_dtbHe10);
    final xepLoaiColor = _getXepLoaiColor(_dtbHe10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Điểm trung bình tích lũy',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _dtbHe10?.toStringAsFixed(2) ?? '--',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  '/10',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Hệ 4: ${_dtbHe4?.toStringAsFixed(2) ?? '--'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: xepLoaiColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  xepLoai,
                  style: TextStyle(
                    color: xepLoaiColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThongKeNhanh() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tín chỉ đạt',
            value: _tinChiDat.toString(),
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Tổng tín chỉ',
            value: _tongTinChi.toString(),
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Môn phần',
            value: _soMonHoc.toString(),
            color: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThongKeDiemChu() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text(
                'Thống kê điểm chữ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _thongKeDiemChu.entries.map((entry) {
              final diemChu = entry.key;
              final soLuong = entry.value;
              final color = _getDiemChuColor(diemChu);

              return Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      diemChu,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        soLuong.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChiTietDiem() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text(
                'Chi tiết điểm học phần',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_diemHocPhans.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Chưa có điểm học phần nào'),
              ),
            )
          else
            ..._diemHocPhans.map((hp) => _buildDiemHocPhanItem(hp)),
        ],
      ),
    );
  }

  Widget _buildDiemHocPhanItem(Map<String, dynamic> hp) {
    final tenHocPhan = hp['tenhocphan'] ?? 'Không rõ';
    final maHocPhan = hp['mahocphan'] ?? '';
    final tinChi = hp['tinchi'] ?? 0;
    final diemA = (hp['diem_a'] as num?)?.toDouble();
    final diemB = (hp['diem_b'] as num?)?.toDouble();
    final diemC = (hp['diem_c'] as num?)?.toDouble();
    final diemTongKet = (hp['diem_tong_ket'] as num?)?.toDouble();
    final diemChu = hp['diem_chu'] as String?;
    final diemHe4 = (hp['diem_he_4'] as num?)?.toDouble();

    final diemChuColor = diemChu != null ? _getDiemChuColor(diemChu) : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Điểm chữ + Tên học phần
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Điểm chữ
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: diemChuColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    diemChu ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Thông tin học phần
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenHocPhan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(maHocPhan, Colors.blue),
                        const SizedBox(width: 8),
                        _buildInfoChip('$tinChi TC', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chi tiết điểm
          Row(
            children: [
              Expanded(
                child: _buildDiemBox('Chuyên cần', diemA),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDiemBox('Giữa kỳ', diemB),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDiemBox('Cuối kỳ', diemC),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDiemBox(
                  'Tổng kết',
                  diemTongKet,
                  isHighlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Công thức tính điểm
          Center(
            child: Text(
              'Điểm hệ 4: ${diemHe4?.toStringAsFixed(2) ?? '--'}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Center(
            child: Text(
              'Công thức: 0.1×A + 0.4×B + 0.5×C',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDiemBox(String label, double? value, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF2196F3).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight ? const Color(0xFF2196F3) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            value?.toStringAsFixed(1) ?? '--',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isHighlight ? const Color(0xFF2196F3) : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
