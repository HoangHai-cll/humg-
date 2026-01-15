import '../models/hoc_phan.dart';
import '../utils/database_helper.dart';

class HocPhanRepository {
  final DatabaseHelper _db;

  HocPhanRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  /// Lấy tất cả học phần
  List<HocPhan> findAll({int? limit, int? offset}) {
    var sql = 'SELECT * FROM HocPhan ORDER BY tenhocphan ASC';
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
    return DatabaseHelper.resultSetToList(result).map(HocPhan.fromMap).toList();
  }

  /// Tìm học phần theo mã
  HocPhan? findByMa(String mahocphan) {
    final result = _db.database.select(
      'SELECT * FROM HocPhan WHERE mahocphan = ?',
      [mahocphan],
    );
    if (result.isEmpty) return null;
    return HocPhan.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Tìm kiếm học phần theo tên
  List<HocPhan> searchByName(String keyword) {
    final result = _db.database.select(
      'SELECT * FROM HocPhan WHERE tenhocphan LIKE ? ORDER BY tenhocphan',
      ['%$keyword%'],
    );
    return DatabaseHelper.resultSetToList(result).map(HocPhan.fromMap).toList();
  }

  /// Thêm học phần mới
  HocPhan? create(HocPhan hocPhan) {
    if (findByMa(hocPhan.mahocphan) != null) {
      throw Exception('Mã học phần đã tồn tại');
    }

    _db.database.execute('''
      INSERT INTO HocPhan (mahocphan, tenhocphan, tinchi)
      VALUES (?, ?, ?)
    ''', [hocPhan.mahocphan, hocPhan.tenhocphan, hocPhan.tinchi]);

    return findByMa(hocPhan.mahocphan);
  }

  /// Cập nhật học phần
  HocPhan? update(String mahocphan, Map<String, dynamic> data) {
    final existing = findByMa(mahocphan);
    if (existing == null) return null;

    final sets = <String>[];
    final params = <dynamic>[];

    if (data.containsKey('tenhocphan')) {
      sets.add('tenhocphan = ?');
      params.add(data['tenhocphan']);
    }
    if (data.containsKey('tinchi')) {
      sets.add('tinchi = ?');
      params.add(data['tinchi']);
    }

    if (sets.isEmpty) return existing;

    params.add(mahocphan);
    _db.database.execute(
      'UPDATE HocPhan SET ${sets.join(', ')} WHERE mahocphan = ?',
      params,
    );

    return findByMa(mahocphan);
  }

  /// Xóa học phần
  bool delete(String mahocphan) {
    // Xóa điểm liên quan
    _db.database
        .execute('DELETE FROM DiemHocPhan WHERE mahocphan = ?', [mahocphan]);
    // Xóa lớp học phần liên quan
    _db.database
        .execute('DELETE FROM LopHocPhan WHERE mahocphan = ?', [mahocphan]);
    // Xóa học phần
    _db.database
        .execute('DELETE FROM HocPhan WHERE mahocphan = ?', [mahocphan]);
    return _db.database.updatedRows > 0;
  }

  /// Đếm tổng số học phần
  int count() {
    final result = _db.database.select('SELECT COUNT(*) as count FROM HocPhan');
    return result.first['count'] as int;
  }

  /// Lấy học phần theo lớp và học kỳ
  List<HocPhan> findByLopAndHocKy(String malop, String hocky, String namhoc) {
    final result = _db.database.select('''
      SELECT hp.* FROM HocPhan hp
      JOIN LopHocPhan lhp ON hp.mahocphan = lhp.mahocphan
      WHERE lhp.malop = ? AND lhp.hocky = ? AND lhp.namhoc = ?
      ORDER BY hp.tenhocphan
    ''', [malop, hocky, namhoc]);
    return DatabaseHelper.resultSetToList(result).map(HocPhan.fromMap).toList();
  }
}
