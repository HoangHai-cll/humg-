import '../models/sinh_vien.dart';
import '../utils/database_helper.dart';

class SinhVienRepository {
  final DatabaseHelper _db;

  SinhVienRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Lấy tất cả sinh viên
  List<SinhVien> findAll({int? limit, int? offset, String? malop}) {
    var sql = 'SELECT * FROM SinhVien';
    final params = <dynamic>[];
    final conditions = <String>[];

    if (malop != null) {
      conditions.add('malop = ?');
      params.add(malop);
    }

    if (conditions.isNotEmpty) {
      sql += ' WHERE ${conditions.join(' AND ')}';
    }

    sql += ' ORDER BY ten ASC';

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
        .map(SinhVien.fromMap)
        .toList();
  }

  /// Tìm sinh viên theo MSV
  SinhVien? findByMsv(String msv) {
    final result = _db.database.select(
      'SELECT * FROM SinhVien WHERE msv = ?',
      [msv],
    );
    if (result.isEmpty) return null;
    return SinhVien.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Tìm kiếm sinh viên theo tên
  List<SinhVien> searchByName(String keyword) {
    final result = _db.database.select(
      "SELECT * FROM SinhVien WHERE hodem || ' ' || ten LIKE ? ORDER BY ten",
      ['%$keyword%'],
    );
    return DatabaseHelper.resultSetToList(result)
        .map(SinhVien.fromMap)
        .toList();
  }

  /// Thêm sinh viên mới
  SinhVien? create(SinhVien sinhVien) {
    // Kiểm tra MSV đã tồn tại
    if (findByMsv(sinhVien.msv) != null) {
      throw Exception('Mã sinh viên đã tồn tại');
    }

    _db.database.execute('''
      INSERT INTO SinhVien (msv, hodem, ten, ngaysinh, gioitinh, malop)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      sinhVien.msv,
      sinhVien.hodem,
      sinhVien.ten,
      sinhVien.ngaysinh.toIso8601String().split('T')[0],
      sinhVien.gioitinh,
      sinhVien.malop,
    ]);

    // Cập nhật sĩ số lớp
    _updateSiSo(sinhVien.malop);

    return findByMsv(sinhVien.msv);
  }

  /// Cập nhật sinh viên
  SinhVien? update(String msv, Map<String, dynamic> data) {
    final existing = findByMsv(msv);
    if (existing == null) return null;

    final oldMalop = existing.malop;
    final sets = <String>[];
    final params = <dynamic>[];

    if (data.containsKey('hodem')) {
      sets.add('hodem = ?');
      params.add(data['hodem']);
    }
    if (data.containsKey('ten')) {
      sets.add('ten = ?');
      params.add(data['ten']);
    }
    if (data.containsKey('ngaysinh')) {
      sets.add('ngaysinh = ?');
      params.add(data['ngaysinh']);
    }
    if (data.containsKey('gioitinh')) {
      sets.add('gioitinh = ?');
      params.add(data['gioitinh']);
    }
    if (data.containsKey('malop')) {
      sets.add('malop = ?');
      params.add(data['malop']);
    }

    if (sets.isEmpty) return existing;

    params.add(msv);
    _db.database.execute(
      'UPDATE SinhVien SET ${sets.join(', ')} WHERE msv = ?',
      params,
    );

    // Cập nhật sĩ số nếu đổi lớp
    final newMalop = data['malop'] as String?;
    if (newMalop != null && newMalop != oldMalop) {
      _updateSiSo(oldMalop);
      _updateSiSo(newMalop);
    }

    return findByMsv(msv);
  }

  /// Xóa sinh viên
  bool delete(String msv) {
    final existing = findByMsv(msv);
    if (existing == null) return false;

    // Xóa điểm trước
    _db.database.execute('DELETE FROM DiemHocPhan WHERE msv = ?', [msv]);
    // Xóa tài khoản auth nếu có
    _db.database.execute('DELETE FROM Auth WHERE msv = ?', [msv]);
    // Xóa sinh viên
    _db.database.execute('DELETE FROM SinhVien WHERE msv = ?', [msv]);

    // Cập nhật sĩ số
    _updateSiSo(existing.malop);

    return true;
  }

  /// Đếm tổng số sinh viên
  int count({String? malop}) {
    var sql = 'SELECT COUNT(*) as count FROM SinhVien';
    final params = <dynamic>[];

    if (malop != null) {
      sql += ' WHERE malop = ?';
      params.add(malop);
    }

    final result = _db.database.select(sql, params);
    return result.first['count'] as int;
  }

  /// Lấy thông tin chi tiết sinh viên kèm lớp và khoa
  Map<String, dynamic>? findDetailByMsv(String msv) {
    final result = _db.database.select('''
      SELECT sv.*, l.tenlop, l.hedaotao, l.nienkhoa, k.tenkhoa
      FROM SinhVien sv
      JOIN LopChuyenNganh l ON sv.malop = l.malop
      JOIN KhoaDaoTao k ON l.makhoa = k.makhoa
      WHERE sv.msv = ?
    ''', [msv]);

    if (result.isEmpty) return null;
    return DatabaseHelper.resultSetToList(result).first;
  }

  /// Cập nhật sĩ số lớp
  void _updateSiSo(String malop) {
    _db.database.execute('''
      UPDATE LopChuyenNganh 
      SET siso = (SELECT COUNT(*) FROM SinhVien WHERE malop = ?)
      WHERE malop = ?
    ''', [malop, malop]);
  }

  /// liệt kê tất cả sinh viên của một khoa (nhập mã khoa)
  List<SinhVien> findByKhoa(String makhoa) {
    final result = _db.database.select('''
      SELECT sv.*
      FROM SinhVien sv
      JOIN LopChuyenNganh l ON sv.malop = l.malop
      WHERE l.makhoa = ?
      ORDER BY sv.ten ASC
    ''', [makhoa]);

    return DatabaseHelper.resultSetToList(result)
        .map(SinhVien.fromMap)
        .toList();
  }
  /// Lấy danh sách sinh viên có điểm A >= [diem]
List<Map<String, dynamic>> getSinhVienDiemA(double diem) {
    final result = _db.database.select('''
    SELECT sv.*, dhp.diem_a
    FROM SinhVien sv
    JOIN DiemHocPhan dhp ON sv.msv = dhp.msv
    WHERE dhp.diem_a >= ?
    ORDER BY sv.ten ASC
  ''', [diem]);

    return DatabaseHelper.resultSetToList(result);
  }

Future<List<Map<String, dynamic>>> getSinhVienDiemCThapTheoLop({
    required String lop, 
    required num maxC,
  }) async {
    final result = _db.database.select('''
    SELECT sv.*, dhp.diem_c
    FROM SinhVien sv
    JOIN LopChuyenNganh lcn
         ON sv.malop = lcn.malop
    JOIN DiemHocPhan dhp
         ON sv.msv = dhp.msv
    WHERE lcn.malop = ?
      AND dhp.diem_c <= ?
    ORDER BY sv.ten ASC
  ''', [lop, maxC]);

    return DatabaseHelper.resultSetToList(result);
  }

}
