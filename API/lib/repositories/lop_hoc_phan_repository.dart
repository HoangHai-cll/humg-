
import '../models/lop_hoc_phan.dart';
import '../utils/database_helper.dart';

class LopHocPhanRepository {
  final DatabaseHelper _db;

  LopHocPhanRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Lấy tất cả lớp học phần
  List<LopHocPhan> findAll({String? malop, String? hocky, String? namhoc}) {
    var sql = 'SELECT * FROM LopHocPhan';
    final params = <dynamic>[];
    final conditions = <String>[];

    if (malop != null) {
      conditions.add('malop = ?');
      params.add(malop);
    }
    if (hocky != null) {
      conditions.add('hocky = ?');
      params.add(hocky);
    }
    if (namhoc != null) {
      conditions.add('namhoc = ?');
      params.add(namhoc);
    }

    if (conditions.isNotEmpty) {
      sql += ' WHERE ${conditions.join(' AND ')}';
    }

    sql += ' ORDER BY namhoc DESC, hocky DESC';

    final result = _db.database.select(sql, params);
    return DatabaseHelper.resultSetToList(result)
        .map(LopHocPhan.fromMap)
        .toList();
  }

  /// Tìm lớp học phần cụ thể
  LopHocPhan? findOne(String mahocphan, String malop) {
    final result = _db.database.select(
      'SELECT * FROM LopHocPhan WHERE mahocphan = ? AND malop = ?',
      [mahocphan, malop],
    );
    if (result.isEmpty) return null;
    return LopHocPhan.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Thêm lớp học phần
  LopHocPhan? create(LopHocPhan lopHocPhan) {
    if (findOne(lopHocPhan.mahocphan, lopHocPhan.malop) != null) {
      throw Exception('Lớp học phần đã tồn tại');
    }

    _db.database.execute('''
      INSERT INTO LopHocPhan (mahocphan, malop, hocky, namhoc)
      VALUES (?, ?, ?, ?)
    ''', [
      lopHocPhan.mahocphan,
      lopHocPhan.malop,
      lopHocPhan.hocky,
      lopHocPhan.namhoc
    ]);

    return findOne(lopHocPhan.mahocphan, lopHocPhan.malop);
  }

  /// Cập nhật lớp học phần
  LopHocPhan? update(
      String mahocphan, String malop, Map<String, dynamic> data) {
    final existing = findOne(mahocphan, malop);
    if (existing == null) return null;

    final sets = <String>[];
    final params = <dynamic>[];

    if (data.containsKey('hocky')) {
      sets.add('hocky = ?');
      params.add(data['hocky']);
    }
    if (data.containsKey('namhoc')) {
      sets.add('namhoc = ?');
      params.add(data['namhoc']);
    }

    if (sets.isEmpty) return existing;

    params.addAll([mahocphan, malop]);
    _db.database.execute(
      'UPDATE LopHocPhan SET ${sets.join(', ')} WHERE mahocphan = ? AND malop = ?',
      params,
    );

    return findOne(mahocphan, malop);
  }

  /// Xóa lớp học phần
  bool delete(String mahocphan, String malop) {
    _db.database.execute(
      'DELETE FROM LopHocPhan WHERE mahocphan = ? AND malop = ?',
      [mahocphan, malop],
    );
    return _db.database.updatedRows > 0;
  }

  /// Lấy danh sách học phần của lớp kèm thông tin chi tiết
  List<Map<String, dynamic>> getHocPhanByLop(String malop,
      {String? hocky, String? namhoc}) {
    var sql = '''
      SELECT lhp.*, hp.tenhocphan, hp.tinchi
      FROM LopHocPhan lhp
      JOIN HocPhan hp ON lhp.mahocphan = hp.mahocphan
      WHERE lhp.malop = ?
    ''';
    final params = <dynamic>[malop];

    if (hocky != null) {
      sql += ' AND lhp.hocky = ?';
      params.add(hocky);
    }
    if (namhoc != null) {
      sql += ' AND lhp.namhoc = ?';
      params.add(namhoc);
    }

    sql += ' ORDER BY lhp.namhoc DESC, lhp.hocky DESC, hp.tenhocphan';

    final result = _db.database.select(sql, params);
    return DatabaseHelper.resultSetToList(result);
  }

  /// Lấy tất cả năm học
  List<String> getAllNamHoc() {
    final result = _db.database.select(
      'SELECT DISTINCT namhoc FROM LopHocPhan ORDER BY namhoc DESC',
    );
    return DatabaseHelper.resultSetToList(result)
        .map((row) => row['namhoc'] as String)
        .toList();
  }


    /// Lấy chi tiết các học phần mà sinh viên đã học theo msv
Future<List<Map<String, dynamic>>> getHocPhanChiTietByMsv(String msv) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.select('''
    SELECT
      hp.mahocphan,
      hp.tenhocphan,
      hp.tinchi,
      lhp.hocky,
      lhp.namhoc,
      lcn.tenlop
    FROM DiemHocPhan dhp
    INNER JOIN HocPhan hp 
      ON hp.mahocphan = dhp.mahocphan
    INNER JOIN LopHocPhan lhp 
      ON lhp.mahocphan = hp.mahocphan
    INNER JOIN LopChuyenNganh lcn
      ON lcn.malop = lhp.malop
    WHERE dhp.msv = ?
    ORDER BY lhp.namhoc DESC, lhp.hocky ASC
  ''', [msv]);

    return result;
  }


}
