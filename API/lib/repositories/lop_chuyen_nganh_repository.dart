import '../models/lop_chuyen_nganh.dart';
import '../utils/database_helper.dart';

class LopChuyenNganhRepository {
  final DatabaseHelper _db;

  LopChuyenNganhRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Lấy tất cả lớp
  List<LopChuyenNganh> findAll({int? limit, int? offset, String? makhoa}) {
    var sql = 'SELECT * FROM LopChuyenNganh';
    final params = <dynamic>[];

    if (makhoa != null) {
      sql += ' WHERE makhoa = ?';
      params.add(makhoa);
    }

    sql += ' ORDER BY tenlop ASC';

    if (limit != null) {
      sql += ' LIMIT ?';
      params.add(limit);
      if (offset != null) {
        sql += ' OFFSET ?';
        params.add(offset);
      }
    }

    final result = _db.database.select(sql, params);
    return DatabaseHelper.resultSetToList(result)
        .map(LopChuyenNganh.fromMap)
        .toList();
  }

  /// Tìm lớp theo mã
  LopChuyenNganh? findByMa(String malop) {
    final result = _db.database.select(
      'SELECT * FROM LopChuyenNganh WHERE malop = ?',
      [malop],
    );
    if (result.isEmpty) return null;
    return LopChuyenNganh.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Thêm lớp mới
  LopChuyenNganh? create(LopChuyenNganh lop) {
    if (findByMa(lop.malop) != null) {
      throw Exception('Mã lớp đã tồn tại');
    }

    _db.database.execute('''
      INSERT INTO LopChuyenNganh (malop, tenlop, siso, hedaotao, nienkhoa, makhoa)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      lop.malop,
      lop.tenlop,
      lop.siso,
      lop.hedaotao,
      lop.nienkhoa,
      lop.makhoa
    ]);

    return findByMa(lop.malop);
  }

  /// Cập nhật lớp
  LopChuyenNganh? update(String malop, Map<String, dynamic> data) {
    final existing = findByMa(malop);
    if (existing == null) return null;

    final sets = <String>[];
    final params = <dynamic>[];

    if (data.containsKey('tenlop')) {
      sets.add('tenlop = ?');
      params.add(data['tenlop']);
    }
    if (data.containsKey('hedaotao')) {
      sets.add('hedaotao = ?');
      params.add(data['hedaotao']);
    }
    if (data.containsKey('nienkhoa')) {
      sets.add('nienkhoa = ?');
      params.add(data['nienkhoa']);
    }
    if (data.containsKey('makhoa')) {
      sets.add('makhoa = ?');
      params.add(data['makhoa']);
    }

    if (sets.isEmpty) return existing;

    params.add(malop);
    _db.database.execute(
      'UPDATE LopChuyenNganh SET ${sets.join(', ')} WHERE malop = ?',
      params,
    );

    return findByMa(malop);
  }

  /// Xóa lớp
  bool delete(String malop) {
    // Kiểm tra còn sinh viên không
    final svCount = _db.database.select(
      'SELECT COUNT(*) as count FROM SinhVien WHERE malop = ?',
      [malop],
    );
    if ((svCount.first['count'] as int) > 0) {
      throw Exception('Không thể xóa lớp còn sinh viên');
    }

    // Xóa lớp học phần
    _db.database.execute('DELETE FROM LopHocPhan WHERE malop = ?', [malop]);
    // Xóa lớp
    _db.database.execute('DELETE FROM LopChuyenNganh WHERE malop = ?', [malop]);
    return _db.database.updatedRows > 0;
  }

  /// Đếm tổng số lớp
  int count({String? makhoa}) {
    var sql = 'SELECT COUNT(*) as count FROM LopChuyenNganh';
    final params = <dynamic>[];

    if (makhoa != null) {
      sql += ' WHERE makhoa = ?';
      params.add(makhoa);
    }

    final result = _db.database.select(sql, params);
    return result.first['count'] as int;
  }

  /// Lấy thông tin chi tiết lớp kèm khoa
  Map<String, dynamic>? findDetailByMa(String malop) {
    final result = _db.database.select('''
      SELECT l.*, k.tenkhoa
      FROM LopChuyenNganh l
      JOIN KhoaDaoTao k ON l.makhoa = k.makhoa
      WHERE l.malop = ?
    ''', [malop]);

    if (result.isEmpty) return null;
    return DatabaseHelper.resultSetToList(result).first;
  }
}
