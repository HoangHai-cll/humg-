import '../models/diem_hoc_phan.dart';
import '../utils/database_helper.dart';

class DiemHocPhanRepository {
  final DatabaseHelper _db;

  DiemHocPhanRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  /// Lấy điểm theo MSV
  List<DiemHocPhan> findByMsv(String msv) {
    final result = _db.database.select(
      'SELECT * FROM DiemHocPhan WHERE msv = ?',
      [msv],
    );
    return DatabaseHelper.resultSetToList(result)
        .map(DiemHocPhan.fromMap)
        .toList();
  }

  /// Lấy điểm theo học phần
  List<DiemHocPhan> findByHocPhan(String mahocphan) {
    final result = _db.database.select(
      'SELECT * FROM DiemHocPhan WHERE mahocphan = ?',
      [mahocphan],
    );
    return DatabaseHelper.resultSetToList(result)
        .map(DiemHocPhan.fromMap)
        .toList();
  }

  /// Lấy điểm cụ thể
  DiemHocPhan? findOne(String msv, String mahocphan) {
    final result = _db.database.select(
      'SELECT * FROM DiemHocPhan WHERE msv = ? AND mahocphan = ?',
      [msv, mahocphan],
    );
    if (result.isEmpty) return null;
    return DiemHocPhan.fromMap(DatabaseHelper.resultSetToList(result).first);
  }

  /// Thêm hoặc cập nhật điểm
  DiemHocPhan? upsert(DiemHocPhan diem) {
    final existing = findOne(diem.msv, diem.mahocphan);

    if (existing != null) {
      // Update
      _db.database.execute('''
        UPDATE DiemHocPhan 
        SET diem_a = ?, diem_b = ?, diem_c = ?
        WHERE msv = ? AND mahocphan = ?
      ''', [diem.diemA, diem.diemB, diem.diemC, diem.msv, diem.mahocphan]);
    } else {
      // Insert
      _db.database.execute('''
        INSERT INTO DiemHocPhan (mahocphan, msv, diem_a, diem_b, diem_c)
        VALUES (?, ?, ?, ?, ?)
      ''', [diem.mahocphan, diem.msv, diem.diemA, diem.diemB, diem.diemC]);
    }

    return findOne(diem.msv, diem.mahocphan);
  }

  /// Xóa điểm
  bool delete(String msv, String mahocphan) {
    _db.database.execute(
      'DELETE FROM DiemHocPhan WHERE msv = ? AND mahocphan = ?',
      [msv, mahocphan],
    );
    return _db.database.updatedRows > 0;
  }

  /// Lấy bảng điểm chi tiết của sinh viên
  List<Map<String, dynamic>> getBangDiem(String msv) {
    final result = _db.database.select('''
      SELECT d.*, hp.tenhocphan, hp.tinchi
      FROM DiemHocPhan d
      JOIN HocPhan hp ON d.mahocphan = hp.mahocphan
      WHERE d.msv = ?
      ORDER BY hp.tenhocphan
    ''', [msv],);

    return DatabaseHelper.resultSetToList(result).map((row) {
      final diem = DiemHocPhan.fromMap(row);
      return {
        ...row,
        'diem_tong_ket': diem.diemTongKet,
        'diem_chu': diem.diemChu,
        'diem_he_4': diem.diemHe4,
      };
    }).toList();
  }

  /// Tính điểm trung bình tích lũy
  Map<String, dynamic> tinhDTBTichLuy(String msv) {
    final result = _db.database.select('''
      SELECT d.*, hp.tinchi
      FROM DiemHocPhan d
      JOIN HocPhan hp ON d.mahocphan = hp.mahocphan
      WHERE d.msv = ? AND d.diem_c IS NOT NULL
    ''', [msv]);

    final rows = DatabaseHelper.resultSetToList(result);
    if (rows.isEmpty) {
      return {
        'dtb_he_10': null,
        'dtb_he_4': null,
        'tong_tin_chi': 0,
        'tin_chi_dat': 0,
      };
    }

    var tongDiem10 = 0.0;
    var tongDiem4 = 0.0;
    var tongTinChi = 0;
    var tinChiDat = 0;

    for (final row in rows) {
      final diem = DiemHocPhan.fromMap(row);
      final tinChi = row['tinchi'] as int;
      final dtk = diem.diemTongKet;
      final d4 = diem.diemHe4;

      if (dtk != null && d4 != null) {
        tongDiem10 += dtk * tinChi;
        tongDiem4 += d4 * tinChi;
        tongTinChi += tinChi;
        if (dtk >= 4.0) {
          tinChiDat += tinChi;
        }
      }
    }

    return {
      'dtb_he_10': tongTinChi > 0 ? (tongDiem10 / tongTinChi) : null,
      'dtb_he_4': tongTinChi > 0 ? (tongDiem4 / tongTinChi) : null,
      'tong_tin_chi': tongTinChi,
      'tin_chi_dat': tinChiDat,
    };
  }

  /// Lấy điểm của lớp theo học phần
  List<Map<String, dynamic>> getDiemLop(String malop, String mahocphan) {
    final result = _db.database.select('''
      SELECT d.*, sv.hodem, sv.ten
      FROM DiemHocPhan d
      JOIN SinhVien sv ON d.msv = sv.msv
      WHERE sv.malop = ? AND d.mahocphan = ?
      ORDER BY sv.ten
    ''', [malop, mahocphan]);

    return DatabaseHelper.resultSetToList(result).map((row) {
      final diem = DiemHocPhan.fromMap(row);
      return {
        ...row,
        'ho_ten': '${row['hodem']} ${row['ten']}',
        'diem_tong_ket': diem.diemTongKet,
        'diem_chu': diem.diemChu,
      };
    }).toList();
  }

  /// Thống kê điểm của học phần
  Map<String, dynamic> thongKeDiem(String mahocphan) {
    final diems = findByHocPhan(mahocphan);
    if (diems.isEmpty) {
      return {
        'total': 0,
        'passed': 0,
        'failed': 0,
        'average': null,
        'highest': null,
        'lowest': null,
      };
    }

    final validDiems = diems.where((d) => d.diemTongKet != null).toList();
    if (validDiems.isEmpty) {
      return {
        'total': diems.length,
        'passed': 0,
        'failed': 0,
        'average': null,
        'highest': null,
        'lowest': null,
      };
    }

    final scores = validDiems.map((d) => d.diemTongKet!).toList();
    final passed = scores.where((s) => s >= 4.0).length;

    return {
      'total': diems.length,
      'graded': validDiems.length,
      'passed': passed,
      'failed': validDiems.length - passed,
      'pass_rate': (passed / validDiems.length * 100).toStringAsFixed(1),
      'average':
          (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(2),
      'highest': scores.reduce((a, b) => a > b ? a : b).toStringAsFixed(2),
      'lowest': scores.reduce((a, b) => a < b ? a : b).toStringAsFixed(2),
    };
  }
}
