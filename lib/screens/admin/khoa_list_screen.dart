import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class KhoaListScreen extends StatefulWidget {
  const KhoaListScreen({super.key});

  @override
  State<KhoaListScreen> createState() => _KhoaListScreenState();
}

class _KhoaListScreenState extends State<KhoaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadKhoas();
    });
  }

  void _showAddDialog() {
    final makhoaController = TextEditingController();
    final tenkhoaController = TextEditingController();
    final sdtController = TextEditingController();
    final emailController = TextEditingController();
    final websiteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Khoa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: makhoaController,
                decoration: const InputDecoration(labelText: 'Mã khoa *'),
              ),
              TextField(
                controller: tenkhoaController,
                decoration: const InputDecoration(labelText: 'Tên khoa *'),
              ),
              TextField(
                controller: sdtController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
                keyboardType: TextInputType.url,
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
              final result = await context.read<AdminProvider>().createKhoa(
                makhoa: makhoaController.text,
                tenkhoa: tenkhoaController.text,
                sdt: sdtController.text.isNotEmpty ? sdtController.text : null,
                email: emailController.text.isNotEmpty
                    ? emailController.text
                    : null,
                website: websiteController.text.isNotEmpty
                    ? websiteController.text
                    : null,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? 'Thêm khoa thành công'
                          : result['message'] ?? 'Lỗi thêm khoa',
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

  void _showEditDialog(Map<String, dynamic> khoa) {
    final tenkhoaController = TextEditingController(text: khoa['tenkhoa']);
    final sdtController = TextEditingController(text: khoa['sdt'] ?? '');
    final emailController = TextEditingController(text: khoa['email'] ?? '');
    final websiteController = TextEditingController(
      text: khoa['website'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa: ${khoa['makhoa']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tenkhoaController,
                decoration: const InputDecoration(labelText: 'Tên khoa'),
              ),
              TextField(
                controller: sdtController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: websiteController,
                decoration: const InputDecoration(labelText: 'Website'),
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
                  .updateKhoa(khoa['makhoa'], {
                    'tenkhoa': tenkhoaController.text,
                    'sdt': sdtController.text,
                    'email': emailController.text,
                    'website': websiteController.text,
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

  void _confirmDelete(String makhoa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa khoa $makhoa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await context.read<AdminProvider>().deleteKhoa(
                makhoa,
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
        title: const Text('Quản lý Khoa'),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminProvider>().loadKhoas(),
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
          if (provider.isLoadingKhoa) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.khoas.isEmpty) {
            return const Center(child: Text('Không có khoa nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.khoas.length,
            itemBuilder: (context, index) {
              final khoa = provider.khoas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF9C27B0),
                    child: Text(
                      khoa['makhoa']?.substring(0, 2) ?? 'K',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(khoa['tenkhoa'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã: ${khoa['makhoa']}'),
                      if (khoa['email'] != null)
                        Text(
                          '📧 ${khoa['email']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  isThreeLine: khoa['email'] != null,
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
                        _showEditDialog(khoa);
                      } else if (value == 'delete') {
                        _confirmDelete(khoa['makhoa']);
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
