import '../models/khoa_dao_tao.dart';
import '../utils/database_helper.dart';

class KhoaDaoTaoRepository {
  final DatabaseHelper _db;

  KhoaDaoTaoRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Lấy tất cả khoa
  List<KhoaDaoTao> findAll({int? limit, int? offset}) {
    var sql = 'SELECT * FROM KhoaDaoTao ORDER BY tenkhoa ASC';
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
    return DatabaseHelper.resultSetToList(result)
        .map(KhoaDaoTao.fromMap)
        .toList();
  }

  /// Tìm khoa theo mã
  KhoaDaoTao? findByMa(String makhoa) {
    final result = _db.database.select(
      'SELECT * FROM KhoaDaoTao WHERE makhoa = ?',
      [makhoa],
    );
    if (result.isEmpty) return null;
    return KhoaDaoTao.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Thêm khoa mới
  KhoaDaoTao? create(KhoaDaoTao khoa) {
    if (findByMa(khoa.makhoa) != null) {
      throw Exception('Mã khoa đã tồn tại');
    }

    _db.database.execute('''
      INSERT INTO KhoaDaoTao (makhoa, tenkhoa, sdt, email, website)
      VALUES (?, ?, ?, ?, ?)
    ''', [khoa.makhoa, khoa.tenkhoa, khoa.sdt, khoa.email, khoa.website]);

    return findByMa(khoa.makhoa);
  }

  /// Cập nhật khoa
  KhoaDaoTao? update(String makhoa, Map<String, dynamic> data) {
    final existing = findByMa(makhoa);
    if (existing == null) return null;

    final sets = <String>[];
    final params = <dynamic>[];

    if (data.containsKey('tenkhoa')) {
      sets.add('tenkhoa = ?');
      params.add(data['tenkhoa']);
    }
    if (data.containsKey('sdt')) {
      sets.add('sdt = ?');
      params.add(data['sdt']);
    }
    if (data.containsKey('email')) {
      sets.add('email = ?');
      params.add(data['email']);
    }
    if (data.containsKey('website')) {
      sets.add('website = ?');
      params.add(data['website']);
    }

    if (sets.isEmpty) return existing;

    params.add(makhoa);
    _db.database.execute(
      'UPDATE KhoaDaoTao SET ${sets.join(', ')} WHERE makhoa = ?',
      params,
    );

    return findByMa(makhoa);
  }

  /// Xóa khoa
  bool delete(String makhoa) {
    // Kiểm tra còn lớp không
    final lopCount = _db.database.select(
      'SELECT COUNT(*) as count FROM LopChuyenNganh WHERE makhoa = ?',
      [makhoa],
    );
    if ((lopCount.first['count'] as int) > 0) {
      throw Exception('Không thể xóa khoa còn lớp chuyên ngành');
    }

    _db.database.execute('DELETE FROM KhoaDaoTao WHERE makhoa = ?', [makhoa]);
    return _db.database.updatedRows > 0;
  }

  /// Đếm tổng số khoa
  int count() {
    final result =
        _db.database.select('SELECT COUNT(*) as count FROM KhoaDaoTao');
    return result.first['count'] as int;
  }

  /// Lấy thống kê khoa
  Map<String, dynamic>? getStats(String makhoa) {
    final khoa = findByMa(makhoa);
    if (khoa == null) return null;

    final lopCount = _db.database.select(
      'SELECT COUNT(*) as count FROM LopChuyenNganh WHERE makhoa = ?',
      [makhoa],
    );

    final svCount = _db.database.select('''
      SELECT COUNT(*) as count FROM SinhVien sv
      JOIN LopChuyenNganh l ON sv.malop = l.malop
      WHERE l.makhoa = ?
    ''', [makhoa]);

    return {
      ...khoa.toMap(),
      'so_lop': lopCount.first['count'],
      'so_sinh_vien': svCount.first['count'],
    };
  }
}
