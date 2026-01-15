import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class HocPhanListScreen extends StatefulWidget {
  const HocPhanListScreen({super.key});

  @override
  State<HocPhanListScreen> createState() => _HocPhanListScreenState();
}

class _HocPhanListScreenState extends State<HocPhanListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadHocPhans();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final mahocphanController = TextEditingController();
    final tenhocphanController = TextEditingController();
    final tinchiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Học Phần'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mahocphanController,
                decoration: const InputDecoration(labelText: 'Mã học phần *'),
              ),
              TextField(
                controller: tenhocphanController,
                decoration: const InputDecoration(labelText: 'Tên học phần *'),
              ),
              TextField(
                controller: tinchiController,
                decoration: const InputDecoration(labelText: 'Số tín chỉ *'),
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
              final result = await context.read<AdminProvider>().createHocPhan(
                mahocphan: mahocphanController.text,
                tenhocphan: tenhocphanController.text,
                tinchi: int.tryParse(tinchiController.text) ?? 0,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? 'Thêm học phần thành công'
                          : result['message'] ?? 'Lỗi thêm học phần',
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
    );
  }

  void _showEditDialog(Map<String, dynamic> hp) {
    final tenhocphanController = TextEditingController(text: hp['tenhocphan']);
    final tinchiController = TextEditingController(
      text: hp['tinchi']?.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa: ${hp['mahocphan']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenhocphanController,
                decoration: const InputDecoration(labelText: 'Tên học phần'),
              ),
              TextField(
                controller: tinchiController,
                decoration: const InputDecoration(labelText: 'Số tín chỉ'),
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
              final result = await context.read<AdminProvider>().updateHocPhan(
                hp['mahocphan'],
                {
                  'tenhocphan': tenhocphanController.text,
                  'tinchi': int.tryParse(tinchiController.text) ?? hp['tinchi'],
                },
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
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String mahocphan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa học phần $mahocphan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AdminProvider>().deleteHocPhan(
                mahocphan,
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
        title: const Text('Quản lý Học phần'),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().loadHocPhans(),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm học phần...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AdminProvider>().loadHocPhans();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                context.read<AdminProvider>().loadHocPhans(search: value);
              },
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingHocPhan) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.hocPhans.isEmpty) {
                  return const Center(child: Text('Không có học phần nào'));
                }

                return ListView.builder(
                  itemCount: provider.hocPhans.length,
                  itemBuilder: (context, index) {
                    final hp = provider.hocPhans[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4CAF50),
                          child: Text(
                            '${hp['tinchi']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(hp['tenhocphan'] ?? ''),
                        subtitle: Text(
                          'Mã: ${hp['mahocphan']} | ${hp['tinchi']} tín chỉ',
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
                              _showEditDialog(hp);
                            } else if (value == 'delete') {
                              _confirmDelete(hp['mahocphan']);
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
