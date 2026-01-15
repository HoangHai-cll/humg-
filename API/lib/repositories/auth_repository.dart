import 'package:quanlydaotao_api_backend/models/auth.dart';
import 'package:quanlydaotao_api_backend/utils/database_helper.dart';
import 'package:quanlydaotao_api_backend/utils/password_helper.dart';

class AuthRepository {
  final DatabaseHelper _db;

  AuthRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  /// Tìm user theo email
  Auth? findByEmail(String email) {
    final result = _db.database.select(
      'SELECT * FROM Auth WHERE email = ?',
      [email],
    );
    if (result.isEmpty) return null;
    return Auth.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Tìm user theo ID
  Auth? findById(int id) {
    final result = _db.database.select(
      'SELECT * FROM Auth WHERE id = ?',
      [id],
    );
    if (result.isEmpty) return null;
    return Auth.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Tìm user theo MSV
  Auth? findByMsv(String msv) {
    final result = _db.database.select(
      'SELECT * FROM Auth WHERE msv = ?',
      [msv],
    );
    if (result.isEmpty) return null;
    return Auth.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Đăng ký user mới
  Auth? register(RegisterDto dto) {
    // Kiểm tra email đã tồn tại
    if (findByEmail(dto.email) != null) {
      throw Exception('Email đã được sử dụng');
    }

    // Nếu là sinh viên, kiểm tra MSV đã có tài khoản chưa
    if (dto.msv != null && findByMsv(dto.msv!) != null) {
      throw Exception('Mã sinh viên này đã có tài khoản');
    }

    final now = DateTime.now().toIso8601String();
    final hashedPassword = PasswordHelper.hash(dto.password);
    final role = dto.role ?? 'sinhvien';

    _db.database.execute('''
      INSERT INTO Auth (msv, email, password, role, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [dto.msv, dto.email, hashedPassword, role, now, now]);

    return findByEmail(dto.email);
  }

  /// Xác thực đăng nhập
  Auth? authenticate(LoginDto dto) {
    final user = findByEmail(dto.email);
    if (user == null) return null;

    if (!PasswordHelper.verify(dto.password, user.password)) {
      return null;
    }

    return user;
  }

  /// Cập nhật password
  bool updatePassword(int userId, String newPassword) {
    final hashedPassword = PasswordHelper.hash(newPassword);
    final now = DateTime.now().toIso8601String();

    _db.database.execute('''
      UPDATE Auth SET password = ?, updated_at = ? WHERE id = ?
    ''', [hashedPassword, now, userId]);

    return _db.database.updatedRows > 0;
  }

  /// Lấy tất cả users (chỉ admin)
  List<Auth> findAll({int? limit, int? offset}) {
    var sql = 'SELECT * FROM Auth ORDER BY created_at DESC';
    final params = <dynamic>[];

    if (limit != null) {
      sql += ' LIMIT ?';
      params.add(limit);
      if (offset != null) {
        sql += ' OFFSET ?';
        params.add(offset);
      }
    }

    final result = _db.database.select(sql, params);
    return DatabaseHelper.resultSetToList(result).map(Auth.fromMap).toList();
  }

  /// Đếm tổng số users
  int count() {
    final result = _db.database.select('SELECT COUNT(*) as count FROM Auth');
    return result.first['count'] as int;
  }

  /// Xóa user
  bool delete(int userId) {
    _db.database.execute('DELETE FROM Auth WHERE id = ?', [userId]);
    return _db.database.updatedRows > 0;
  }
}
