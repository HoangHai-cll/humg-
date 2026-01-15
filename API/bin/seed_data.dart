// bin/seed.dart
// Chạy: dart run bin/seed.dart

import '../lib/utils/database_helper.dart';
import 'dart:math';

void main() {
  print('🚀 Khởi tạo database...');

  // Sử dụng DatabaseHelper để tạo database và tables
  final dbHelper = DatabaseHelper.instance;
  final db = dbHelper.database;

  print('✓ Database đã được tạo tại: database/quanlydaotao.db');
  print('\n📝 Đang seed dữ liệu mẫu...\n');

  // Seed Khoa
  _seedKhoa(db);

  // Seed Học phần
  _seedHocPhan(db);

  // Seed Lớp
  _seedLop(db);

  // Seed Sinh viên
  _seedSinhVien(db);

  // Cập nhật sĩ số
  _updateSiSo(db);

  // Seed Lớp học phần
  _seedLopHocPhan(db);

  // Seed Điểm
  _seedDiem(db);

  // Seed tài khoản cho sinh viên
  _seedSinhVienAuth(db);

  // Đóng database
  dbHelper.close();

  print('\n✅ Seed dữ liệu hoàn tất!');
  print('\n📌 Tài khoản admin mặc định:');
  print('   Email: admin@school.edu.vn');
  print('   Password: admin123');
  print('\n📌 Tài khoản sinh viên:');
  print('   Email: <msv>@school.edu.vn (VD: sv001@school.edu.vn)');
  print('   Password mặc định: 123456');
}

void _seedKhoa(dynamic db) {
  try {
    final khoas = [
      [
        'CNTT',
        'Khoa Công nghệ Thông tin',
        '0123456789',
        'cntt@school.edu.vn',
        'https://cntt.school.edu.vn'
      ],
      [
        'KT',
        'Khoa Kinh tế',
        '0123456788',
        'kt@school.edu.vn',
        'https://kt.school.edu.vn'
      ],
      [
        'NN',
        'Khoa Ngoại ngữ',
        '0123456787',
        'nn@school.edu.vn',
        'https://nn.school.edu.vn'
      ],
      [
        'KHTN',
        'Khoa Khoa học Tự nhiên',
        '0123456786',
        'khtn@school.edu.vn',
        'https://khtn.school.edu.vn'
      ],
      [
        'SP',
        'Khoa Sư phạm',
        '0123456785',
        'sp@school.edu.vn',
        'https://sp.school.edu.vn'
      ],
      [
        'KH',
        'Khoa Kỹ thuật',
        '0123456784',
        'kh@school.edu.vn',
        'https://kh.school.edu.vn'
      ],
      [
        'DL',
        'Khoa Du lịch',
        '0123456783',
        'dl@school.edu.vn',
        'https://dl.school.edu.vn'
      ],
    ];

    for (final khoa in khoas) {
      db.execute('''
        INSERT OR IGNORE INTO KhoaDaoTao (makhoa, tenkhoa, sdt, email, website) 
        VALUES (?, ?, ?, ?, ?)
      ''', khoa);
    }
    print('  ✓ Đã thêm ${khoas.length} khoa đào tạo');
  } catch (e) {
    print('  ⚠ Khoa đào tạo: $e');
  }
}

void _seedHocPhan(dynamic db) {
  try {
    final hocPhans = [
      // Công nghệ thông tin (15 môn)
      ['HP001', 'Lập trình cơ bản', 3],
      ['HP002', 'Cấu trúc dữ liệu và giải thuật', 4],
      ['HP003', 'Cơ sở dữ liệu', 3],
      ['HP004', 'Lập trình Web', 3],
      ['HP005', 'Mạng máy tính', 3],
      ['HP006', 'Hệ điều hành', 3],
      ['HP007', 'Lập trình hướng đối tượng', 4],
      ['HP008', 'Trí tuệ nhân tạo', 3],
      ['HP009', 'An toàn bảo mật thông tin', 3],
      ['HP010', 'Phát triển ứng dụng di động', 3],
      ['HP011', 'Công nghệ phần mềm', 3],
      ['HP012', 'Học máy', 4],
      ['HP013', 'Xử lý ảnh số', 3],
      ['HP014', 'Lập trình Python', 3],
      ['HP015', 'DevOps và Cloud Computing', 3],

      // Kinh tế (8 môn)
      ['HP016', 'Kinh tế vi mô', 3],
      ['HP017', 'Kinh tế vĩ mô', 3],
      ['HP018', 'Quản trị kinh doanh', 3],
      ['HP019', 'Marketing căn bản', 3],
      ['HP020', 'Tài chính doanh nghiệp', 3],
      ['HP021', 'Kế toán tài chính', 4],
      ['HP022', 'Thống kê kinh doanh', 3],
      ['HP023', 'Kinh tế lượng', 3],

      // Ngoại ngữ (5 môn)
      ['HP024', 'Tiếng Anh cơ bản', 2],
      ['HP025', 'Tiếng Anh giao tiếp', 2],
      ['HP026', 'Tiếng Anh học thuật', 3],
      ['HP027', 'Tiếng Anh thương mại', 3],
      ['HP028', 'Văn học Anh - Mỹ', 2],

      // Khoa học tự nhiên (5 môn)
      ['HP029', 'Toán cao cấp A1', 4],
      ['HP030', 'Toán cao cấp A2', 4],
      ['HP031', 'Vật lý đại cương', 4],
      ['HP032', 'Hóa học đại cương', 4],
      ['HP033', 'Sinh học đại cương', 3],

      // Sư phạm (3 môn)
      ['HP034', 'Tâm lý học đại cương', 3],
      ['HP035', 'Giáo dục học đại cương', 3],
      ['HP036', 'Phương pháp dạy học', 3],

      // Kỹ thuật (3 môn)
      ['HP037', 'Vẽ kỹ thuật', 3],
      ['HP038', 'Cơ học kỹ thuật', 4],
      ['HP039', 'Kỹ thuật điện tử', 3],

      // Du lịch (3 môn)
      ['HP040', 'Quản trị khách sạn', 3],
      ['HP041', 'Hướng dẫn du lịch', 3],
      ['HP042', 'Marketing du lịch', 3],
    ];

    for (final hp in hocPhans) {
      db.execute('''
        INSERT OR IGNORE INTO HocPhan (mahocphan, tenhocphan, tinchi) 
        VALUES (?, ?, ?)
      ''', hp);
    }
    print('  ✓ Đã thêm ${hocPhans.length} học phần');
  } catch (e) {
    print('  ⚠ Học phần: $e');
  }
}

void _seedLop(dynamic db) {
  try {
    final lops = [
      // Công nghệ thông tin (5 lớp)
      [
        'CNTT01',
        'Công nghệ thông tin K65',
        0,
        'Đại học chính quy',
        '2021-2025',
        'CNTT'
      ],
      [
        'CNTT02',
        'Công nghệ thông tin K66',
        0,
        'Đại học chính quy',
        '2022-2026',
        'CNTT'
      ],
      [
        'CNTT03',
        'Công nghệ thông tin K67',
        0,
        'Đại học chính quy',
        '2023-2027',
        'CNTT'
      ],
      [
        'CNTT04',
        'An toàn thông tin K65',
        0,
        'Đại học chính quy',
        '2021-2025',
        'CNTT'
      ],
      [
        'CNTT05',
        'Khoa học dữ liệu K66',
        0,
        'Đại học chính quy',
        '2022-2026',
        'CNTT'
      ],

      // Kinh tế (3 lớp)
      ['KT01', 'Kinh tế K65', 0, 'Đại học chính quy', '2021-2025', 'KT'],
      ['KT02', 'Kinh tế K66', 0, 'Đại học chính quy', '2022-2026', 'KT'],
      [
        'KT03',
        'Quản trị kinh doanh K65',
        0,
        'Đại học chính quy',
        '2021-2025',
        'KT'
      ],

      // Ngoại ngữ (2 lớp)
      ['NN01', 'Ngôn ngữ Anh K65', 0, 'Đại học chính quy', '2021-2025', 'NN'],
      ['NN02', 'Ngôn ngữ Anh K66', 0, 'Đại học chính quy', '2022-2026', 'NN'],

      // Khoa học tự nhiên (2 lớp)
      ['KHTN01', 'Toán học K65', 0, 'Đại học chính quy', '2021-2025', 'KHTN'],
      ['KHTN02', 'Vật lý K66', 0, 'Đại học chính quy', '2022-2026', 'KHTN'],

      // Sư phạm (1 lớp)
      ['SP01', 'Sư phạm Toán K65', 0, 'Đại học chính quy', '2021-2025', 'SP'],

      // Kỹ thuật (1 lớp)
      ['KH01', 'Kỹ thuật điện K66', 0, 'Đại học chính quy', '2022-2026', 'KH'],

      // Du lịch (1 lớp)
      [
        'DL01',
        'Quản trị Du lịch K66',
        0,
        'Đại học chính quy',
        '2022-2026',
        'DL'
      ],
    ];

    for (final lop in lops) {
      db.execute('''
        INSERT OR IGNORE INTO LopChuyenNganh (malop, tenlop, siso, hedaotao, nienkhoa, makhoa) 
        VALUES (?, ?, ?, ?, ?, ?)
      ''', lop);
    }
    print('  ✓ Đã thêm ${lops.length} lớp chuyên ngành');
  } catch (e) {
    print('  ⚠ Lớp chuyên ngành: $e');
  }
}

void _seedSinhVien(dynamic db) {
  try {
    final random = Random(42); // Seed cố định để kết quả nhất quán
    final hoList = [
      'Nguyễn',
      'Trần',
      'Lê',
      'Phạm',
      'Hoàng',
      'Huỳnh',
      'Phan',
      'Vũ',
      'Võ',
      'Đặng',
      'Bùi',
      'Đỗ',
      'Hồ',
      'Ngô',
      'Dương',
      'Lý',
      'Đinh',
      'Mai',
      'Trương',
      'Tô'
    ];

    final tenDemList = [
      'Văn',
      'Thị',
      'Minh',
      'Hoàng',
      'Thanh',
      'Hữu',
      'Đức',
      'Anh',
      'Quang',
      'Hồng',
      'Phương',
      'Thu',
      'Ngọc',
      'Kim',
      'Bảo',
      'Xuân',
      'Tùng',
      'Hải',
      'Lan',
      'Mai',
      'Thảo',
      'Linh',
      'Duy',
      'Tuấn',
      'Phúc',
      'An',
      'Bình',
      'Cường',
      'Đạt',
      'Giang'
    ];

    final tenList = [
      'An',
      'Bình',
      'Cường',
      'Dũng',
      'Em',
      'Phong',
      'Giang',
      'Hùng',
      'Khoa',
      'Long',
      'Minh',
      'Nam',
      'Oanh',
      'Phương',
      'Quân',
      'Sơn',
      'Tâm',
      'Uyên',
      'Vân',
      'Yến',
      'Hà',
      'Hương',
      'Khánh',
      'Linh',
      'My',
      'Nhung',
      'Thảo',
      'Trang',
      'Vy',
      'Như',
      'Đức',
      'Hải',
      'Kiên',
      'Lâm',
      'Phúc',
      'Toàn',
      'Tuấn',
      'Vinh',
      'Thắng',
      'Trung'
    ];

    final gioiTinh = ['Nam', 'Nữ'];

    final lopList = [
      'CNTT01',
      'CNTT02',
      'CNTT03',
      'CNTT04',
      'CNTT05',
      'KT01',
      'KT02',
      'KT03',
      'NN01',
      'NN02',
      'KHTN01',
      'KHTN02',
      'SP01',
      'KH01',
      'DL01'
    ];

    var count = 0;
    for (var i = 1; i <= 250; i++) {
      final msv = 'SV${i.toString().padLeft(3, '0')}';
      final hodem =
          '${hoList[random.nextInt(hoList.length)]} ${tenDemList[random.nextInt(tenDemList.length)]}';
      final ten = tenList[random.nextInt(tenList.length)];
      final year = 2002 + random.nextInt(3); // 2002-2004
      final month = 1 + random.nextInt(12);
      final day = 1 + random.nextInt(28);
      final ngaysinh =
          '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final gt = gioiTinh[random.nextInt(gioiTinh.length)];
      final malop = lopList[i % lopList.length]; // Phân bổ đều các lớp

      try {
        db.execute('''
          INSERT OR IGNORE INTO SinhVien (msv, hodem, ten, ngaysinh, gioitinh, malop) 
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [msv, hodem, ten, ngaysinh, gt, malop]);
        count++;
      } catch (e) {
        // Bỏ qua lỗi duplicate
      }
    }
    print('  ✓ Đã thêm $count sinh viên');
  } catch (e) {
    print('  ⚠ Sinh viên: $e');
  }
}

void _updateSiSo(dynamic db) {
  try {
    db.execute('''
      UPDATE LopChuyenNganh SET siso = (
        SELECT COUNT(*) FROM SinhVien WHERE SinhVien.malop = LopChuyenNganh.malop
      )
    ''');
    print('  ✓ Đã cập nhật sĩ số các lớp');
  } catch (e) {
    print('  ⚠ Cập nhật sĩ số: $e');
  }
}

void _seedLopHocPhan(dynamic db) {
  try {
    // Mapping lớp với các học phần phù hợp
    final lopHocPhanMap = {
      // CNTT
      'CNTT01': [
        'HP001',
        'HP002',
        'HP003',
        'HP004',
        'HP005',
        'HP006',
        'HP007',
        'HP008',
        'HP029',
        'HP030'
      ],
      'CNTT02': [
        'HP001',
        'HP002',
        'HP003',
        'HP007',
        'HP009',
        'HP010',
        'HP011',
        'HP029',
        'HP024'
      ],
      'CNTT03': [
        'HP001',
        'HP007',
        'HP014',
        'HP010',
        'HP012',
        'HP015',
        'HP024',
        'HP029'
      ],
      'CNTT04': [
        'HP001',
        'HP002',
        'HP003',
        'HP005',
        'HP009',
        'HP011',
        'HP029',
        'HP030'
      ],
      'CNTT05': [
        'HP001',
        'HP002',
        'HP012',
        'HP013',
        'HP014',
        'HP008',
        'HP029',
        'HP030'
      ],

      // KT
      'KT01': [
        'HP016',
        'HP017',
        'HP018',
        'HP019',
        'HP020',
        'HP021',
        'HP022',
        'HP024',
        'HP029'
      ],
      'KT02': [
        'HP016',
        'HP017',
        'HP018',
        'HP020',
        'HP021',
        'HP023',
        'HP024',
        'HP025'
      ],
      'KT03': [
        'HP018',
        'HP019',
        'HP020',
        'HP021',
        'HP022',
        'HP024',
        'HP025',
        'HP029'
      ],

      // NN
      'NN01': ['HP024', 'HP025', 'HP026', 'HP027', 'HP028', 'HP034'],
      'NN02': ['HP024', 'HP025', 'HP026', 'HP027', 'HP028', 'HP035'],

      // KHTN
      'KHTN01': ['HP029', 'HP030', 'HP031', 'HP032', 'HP033', 'HP024'],
      'KHTN02': ['HP029', 'HP030', 'HP031', 'HP032', 'HP024', 'HP001'],

      // SP
      'SP01': ['HP029', 'HP030', 'HP034', 'HP035', 'HP036', 'HP024'],

      // KH
      'KH01': ['HP029', 'HP030', 'HP031', 'HP037', 'HP038', 'HP039', 'HP024'],

      // DL
      'DL01': ['HP040', 'HP041', 'HP042', 'HP018', 'HP019', 'HP024', 'HP025'],
    };

    final hocKyList = ['1', '2', '1', '2'];
    final namHocList = ['2021-2022', '2021-2022', '2022-2023', '2022-2023'];

    var count = 0;
    lopHocPhanMap.forEach((malop, hocPhans) {
      for (var i = 0; i < hocPhans.length; i++) {
        final mahocphan = hocPhans[i];
        final hocky = hocKyList[i % hocKyList.length];
        final namhoc = namHocList[i % namHocList.length];

        try {
          db.execute('''
            INSERT OR IGNORE INTO LopHocPhan (mahocphan, malop, hocky, namhoc) 
            VALUES (?, ?, ?, ?)
          ''', [mahocphan, malop, hocky, namhoc]);
          count++;
        } catch (e) {
          // Bỏ qua lỗi duplicate
        }
      }
    });

    print('  ✓ Đã thêm $count lớp học phần');
  } catch (e) {
    print('  ⚠ Lớp học phần: $e');
  }
}

void _seedDiem(dynamic db) {
  try {
    final random = Random(123); // Seed cố định

    // Lấy danh sách tất cả sinh viên và lớp học phần của họ
    final students = db.select('''
      SELECT DISTINCT sv.msv, sv.malop
      FROM SinhVien sv
    ''') as List;

    var count = 0;
    for (final student in students) {
      final msv = student['msv'] as String;
      final malop = student['malop'] as String;

      // Lấy các học phần của lớp này
      final hocPhans = db.select('''
        SELECT DISTINCT mahocphan 
        FROM LopHocPhan 
        WHERE malop = ?
      ''', [malop]) as List;

      // Tạo điểm cho 60-80% số học phần (mô phỏng sinh viên chưa học hết)
      final numHocPhan = hocPhans.length;
      final numDiem = (numHocPhan * (0.6 + random.nextDouble() * 0.2)).round();

      for (var i = 0; i < numDiem && i < hocPhans.length; i++) {
        final mahocphan = hocPhans[i]['mahocphan'] as String;

        // Tạo điểm ngẫu nhiên với phân phối gần thực tế
        // Điểm trung bình khoảng 7-8
        final diemA = 5.0 + random.nextDouble() * 5.0; // 5-10
        final diemB = 5.0 + random.nextDouble() * 5.0; // 5-10
        final diemC = 5.0 + random.nextDouble() * 5.0; // 5-10

        try {
          db.execute('''
            INSERT OR IGNORE INTO DiemHocPhan (mahocphan, msv, diem_a, diem_b, diem_c) 
            VALUES (?, ?, ?, ?, ?)
          ''', [
            mahocphan,
            msv,
            diemA.toStringAsFixed(1),
            diemB.toStringAsFixed(1),
            diemC.toStringAsFixed(1)
          ]);
          count++;
        } catch (e) {
          // Bỏ qua lỗi duplicate
        }
      }
    }

    print('  ✓ Đã thêm $count bản ghi điểm');
  } catch (e) {
    print('  ⚠ Điểm: $e');
  }
}

void _seedSinhVienAuth(dynamic db) {
  try {
    // Lấy tất cả sinh viên từ bảng SinhVien
    final result = db.select('SELECT msv FROM SinhVien') as List;

    final now = DateTime.now().toIso8601String();
    // Password mặc định: 123456 (đã hash với SHA256)
    const defaultPassword =
        '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';

    var count = 0;
    for (final row in result) {
      final msv = row['msv'] as String;
      final email = '${msv.toLowerCase()}@school.edu.vn';

      // Kiểm tra email đã tồn tại chưa
      final existing =
          db.select('SELECT id FROM Auth WHERE email = ?', [email]) as List;
      if (existing.isEmpty) {
        db.execute('''
          INSERT INTO Auth (msv, email, password, role, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [msv, email, defaultPassword, 'sinhvien', now, now]);
        count++;
      }
    }

    print('  ✓ Đã tạo $count tài khoản sinh viên');
    print('    (Email: <msv>@school.edu.vn, Password mặc định: 123456)');
  } catch (e) {
    print('  ⚠ Tài khoản sinh viên: $e');
  }
}
