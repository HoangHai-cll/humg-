import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class DiemManagementScreen extends StatefulWidget {
  const DiemManagementScreen({super.key});

  @override
  State<DiemManagementScreen> createState() => _DiemManagementScreenState();
}

class _DiemManagementScreenState extends State<DiemManagementScreen> {
  final _msvController = TextEditingController();
  List<dynamic> _bangDiem = [];
  Map<String, dynamic>? _tongKet;
  bool _isLoading = false;
  String? _currentMsv;

  @override
  void dispose() {
    _msvController.dispose();
    super.dispose();
  }

  Future<void> _loadBangDiem() async {
    if (_msvController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final result = await context.read<AdminProvider>().getBangDiem(
      _msvController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _currentMsv = _msvController.text.trim();
        _bangDiem = result['data']['diem_hoc_phan'] ?? [];
        _tongKet = result['data']['tong_ket'];
      } else {
        _bangDiem = [];
        _tongKet = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Không tìm thấy'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showAddDiemDialog() {
    final mahocphanController = TextEditingController();
    final diemAController = TextEditingController();
    final diemBController = TextEditingController();
    final diemCController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập điểm cho $_currentMsv'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mahocphanController,
                decoration: const InputDecoration(labelText: 'Mã học phần *'),
              ),
              TextField(
                controller: diemAController,
                decoration: const InputDecoration(
                  labelText: 'Điểm A (chuyên cần)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diemBController,
                decoration: const InputDecoration(
                  labelText: 'Điểm B (giữa kỳ)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diemCController,
                decoration: const InputDecoration(
                  labelText: 'Điểm C (cuối kỳ)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AdminProvider>().upsertDiem(
                msv: _currentMsv!,
                mahocphan: mahocphanController.text,
                diemA: double.tryParse(diemAController.text),
                diemB: double.tryParse(diemBController.text),
                diemC: double.tryParse(diemCController.text),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? 'Lưu điểm thành công'
                          : result['message'] ?? 'Lỗi lưu điểm',
                    ),
                    backgroundColor: result['success'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                );

                if (result['success'] == true) {
                  _loadBangDiem();
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditDiemDialog(Map<String, dynamic> diem) {
    final diemAController = TextEditingController(
      text: diem['diem_a']?.toString() ?? '',
    );
    final diemBController = TextEditingController(
      text: diem['diem_b']?.toString() ?? '',
    );
    final diemCController = TextEditingController(
      text: diem['diem_c']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa điểm: ${diem['tenhocphan']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: diemAController,
                decoration: const InputDecoration(
                  labelText: 'Điểm A (chuyên cần)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diemBController,
                decoration: const InputDecoration(
                  labelText: 'Điểm B (giữa kỳ)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diemCController,
                decoration: const InputDecoration(
                  labelText: 'Điểm C (cuối kỳ)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AdminProvider>().upsertDiem(
                msv: _currentMsv!,
                mahocphan: diem['mahocphan'],
                diemA: double.tryParse(diemAController.text),
                diemB: double.tryParse(diemBController.text),
                diemC: double.tryParse(diemCController.text),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? 'Cập nhật thành công'
                          : result['message'] ?? 'Lỗi cập nhật',
                    ),
                    backgroundColor: result['success'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                );

                if (result['success'] == true) {
                  _loadBangDiem();
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Điểm')),
      floatingActionButton: _currentMsv != null
          ? FloatingActionButton(
              onPressed: _showAddDiemDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // Search by MSV
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msvController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã sinh viên...',
                      prefixIcon: const Icon(Icons.person_search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _loadBangDiem(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loadBangDiem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Tìm'),
                ),
              ],
            ),
          ),

          // Loading
          if (_isLoading) const LinearProgressIndicator(),

          // Tổng kết
          if (_tongKet != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'ĐTB (Hệ 10)',
                    _tongKet!['dtb_he_10'] != null
                        ? (_tongKet!['dtb_he_10'] as num).toStringAsFixed(2)
                        : '-',
                  ),
                  _buildStatItem(
                    'ĐTB (Hệ 4)',
                    _tongKet!['dtb_he_4'] != null
                        ? (_tongKet!['dtb_he_4'] as num).toStringAsFixed(2)
                        : '-',
                  ),
                  _buildStatItem(
                    'Tín chỉ',
                    '${_tongKet!['tin_chi_dat']}/${_tongKet!['tong_tin_chi']}',
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Bảng điểm
          Expanded(
            child: _bangDiem.isEmpty
                ? Center(
                    child: Text(
                      _currentMsv != null
                          ? 'Chưa có điểm nào'
                          : 'Nhập MSV để xem bảng điểm',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _bangDiem.length,
                    itemBuilder: (context, index) {
                      final diem = _bangDiem[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getGradeColor(diem['diem_chu']),
                            child: Text(
                              diem['diem_chu'] ?? '-',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(diem['tenhocphan'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${diem['mahocphan']} | ${diem['tinchi']} TC',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildScoreChip('A', diem['diem_a']),
                                  const SizedBox(width: 8),
                                  _buildScoreChip('B', diem['diem_b']),
                                  const SizedBox(width: 8),
                                  _buildScoreChip('C', diem['diem_c']),
                                  const Spacer(),
                                  Text(
                                    'TK: ${diem['diem_tong_ket']?.toStringAsFixed(1) ?? '-'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDiemDialog(diem),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildScoreChip(String label, dynamic score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${score?.toString() ?? '-'}',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D+':
      case 'D':
        return Colors.amber;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
