import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class LopListScreen extends StatefulWidget {
  const LopListScreen({super.key});

  @override
  State<LopListScreen> createState() => _LopListScreenState();
}

class _LopListScreenState extends State<LopListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadLops();
    });
  }

  void _showAddDialog() {
    final malopController = TextEditingController();
    final tenlopController = TextEditingController();
    final hedaotaoController = TextEditingController(text: 'Đại học chính quy');
    final nienkhoaController = TextEditingController();
    final makhoaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Lớp'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: malopController,
                decoration: const InputDecoration(labelText: 'Mã lớp *'),
              ),
              TextField(
                controller: tenlopController,
                decoration: const InputDecoration(labelText: 'Tên lớp *'),
              ),
              TextField(
                controller: hedaotaoController,
                decoration: const InputDecoration(labelText: 'Hệ đào tạo *'),
              ),
              TextField(
                controller: nienkhoaController,
                decoration: const InputDecoration(
                  labelText: 'Niên khóa * (VD: 2021-2025)',
                ),
              ),
              TextField(
                controller: makhoaController,
                decoration: const InputDecoration(labelText: 'Mã khoa *'),
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
              final result = await context.read<AdminProvider>().createLop(
                malop: malopController.text,
                tenlop: tenlopController.text,
                hedaotao: hedaotaoController.text,
                nienkhoa: nienkhoaController.text,
                makhoa: makhoaController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? 'Thêm lớp thành công'
                          : result['message'] ?? 'Lỗi thêm lớp',
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

  void _showEditDialog(Map<String, dynamic> lop) {
    final tenlopController = TextEditingController(text: lop['tenlop']);
    final hedaotaoController = TextEditingController(text: lop['hedaotao']);
    final nienkhoaController = TextEditingController(text: lop['nienkhoa']);
    final makhoaController = TextEditingController(text: lop['makhoa']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa: ${lop['malop']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenlopController,
                decoration: const InputDecoration(labelText: 'Tên lớp'),
              ),
              TextField(
                controller: hedaotaoController,
                decoration: const InputDecoration(labelText: 'Hệ đào tạo'),
              ),
              TextField(
                controller: nienkhoaController,
                decoration: const InputDecoration(labelText: 'Niên khóa'),
              ),
              TextField(
                controller: makhoaController,
                decoration: const InputDecoration(labelText: 'Mã khoa'),
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
                  .updateLop(lop['malop'], {
                    'tenlop': tenlopController.text,
                    'hedaotao': hedaotaoController.text,
                    'nienkhoa': nienkhoaController.text,
                    'makhoa': makhoaController.text,
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
    );
  }

  void _confirmDelete(String malop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa lớp $malop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AdminProvider>().deleteLop(
                malop,
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
        title: const Text('Quản lý Lớp'),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().loadLops(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingLop) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.lops.isEmpty) {
            return const Center(child: Text('Không có lớp nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.lops.length,
            itemBuilder: (context, index) {
              final lop = provider.lops[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFF9800),
                    child: Text(
                      '${lop['siso'] ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(lop['tenlop'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã: ${lop['malop']} | Khoa: ${lop['makhoa']}'),
                      Text(
                        '${lop['hedaotao']} | ${lop['nienkhoa']}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: true,
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
                        _showEditDialog(lop);
                      } else if (value == 'delete') {
                        _confirmDelete(lop['malop']);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
