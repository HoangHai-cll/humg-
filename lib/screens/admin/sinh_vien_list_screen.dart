import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class SinhVienListScreen extends StatefulWidget {
  const SinhVienListScreen({super.key});

  @override
  State<SinhVienListScreen> createState() => _SinhVienListScreenState();
}

class _SinhVienListScreenState extends State<SinhVienListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSinhViens();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final msvController = TextEditingController();
    final hodemController = TextEditingController();
    final tenController = TextEditingController();
    final ngaysinhController = TextEditingController();
    final malopController = TextEditingController();
    String gioitinh = 'Nam';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm Sinh Viên'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: msvController,
                  decoration: const InputDecoration(
                    labelText: 'Mã sinh viên *',
                  ),
                ),
                TextField(
                  controller: hodemController,
                  decoration: const InputDecoration(labelText: 'Họ đệm *'),
                ),
                TextField(
                  controller: tenController,
                  decoration: const InputDecoration(labelText: 'Tên *'),
                ),
                TextField(
                  controller: ngaysinhController,
                  decoration: const InputDecoration(
                    labelText: 'Ngày sinh * (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: gioitinh,
                  decoration: const InputDecoration(labelText: 'Giới tính'),
                  items: const [
                    DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                    DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  ],
                  onChanged: (value) => setState(() => gioitinh = value!),
                ),
                TextField(
                  controller: malopController,
                  decoration: const InputDecoration(labelText: 'Mã lớp *'),
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
                final result = await context
                    .read<AdminProvider>()
                    .createSinhVien(
                      msv: msvController.text,
                      hodem: hodemController.text,
                      ten: tenController.text,
                      ngaysinh: ngaysinhController.text,
                      gioitinh: gioitinh,
                      malop: malopController.text,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['success'] == true
                            ? 'Thêm sinh viên thành công'
                            : result['message'] ?? 'Lỗi thêm sinh viên',
                      ),
                      backgroundColor: result['success'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> sv) {
    final hodemController = TextEditingController(text: sv['hodem']);
    final tenController = TextEditingController(text: sv['ten']);
    final ngaysinhController = TextEditingController(text: sv['ngaysinh']);
    final malopController = TextEditingController(text: sv['malop']);
    String gioitinh = sv['gioitinh'] ?? 'Nam';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Sửa: ${sv['msv']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hodemController,
                  decoration: const InputDecoration(labelText: 'Họ đệm'),
                ),
                TextField(
                  controller: tenController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
                TextField(
                  controller: ngaysinhController,
                  decoration: const InputDecoration(labelText: 'Ngày sinh'),
                ),
                DropdownButtonFormField<String>(
                  value: gioitinh,
                  decoration: const InputDecoration(labelText: 'Giới tính'),
                  items: const [
                    DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                    DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  ],
                  onChanged: (value) => setState(() => gioitinh = value!),
                ),
                TextField(
                  controller: malopController,
                  decoration: const InputDecoration(labelText: 'Mã lớp'),
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
                final result = await context
                    .read<AdminProvider>()
                    .updateSinhVien(sv['msv'], {
                      'hodem': hodemController.text,
                      'ten': tenController.text,
                      'ngaysinh': ngaysinhController.text,
                      'gioitinh': gioitinh,
                      'malop': malopController.text,
                    });

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
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String msv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sinh viên $msv?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AdminProvider>().deleteSinhVien(
                msv,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Đã xóa'),
                    backgroundColor: result['success'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sinh viên'),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().loadSinhViens(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sinh viên...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AdminProvider>().loadSinhViens();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                context.read<AdminProvider>().loadSinhViens(search: value);
              },
            ),
          ),

          // List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingSinhVien) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.sinhViens.isEmpty) {
                  return const Center(child: Text('Không có sinh viên nào'));
                }

                return ListView.builder(
                  itemCount: provider.sinhViens.length,
                  itemBuilder: (context, index) {
                    final sv = provider.sinhViens[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2196F3),
                          child: Text(
                            sv['ten']?.substring(0, 1) ?? 'S',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('${sv['hodem']} ${sv['ten']}'),
                        subtitle: Text(
                          'MSV: ${sv['msv']} | Lớp: ${sv['malop']}',
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Sửa'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(sv);
                            } else if (value == 'delete') {
                              _confirmDelete(sv['msv']);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
