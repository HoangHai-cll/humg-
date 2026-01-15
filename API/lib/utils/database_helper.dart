import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Database get database {
    _database ??= _initDatabase();
    return _database!;
  }

  Database _initDatabase() {
    final dbPath =
        Platform.environment['DATABASE_PATH'] ?? 'database/quanlydaotao.db';

    // Đảm bảo thư mục tồn tại
    final dbDir = Directory(dbPath).parent;
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }

    final db = sqlite3.open(dbPath);
    _createTables(db);
    return db;
  }

  void _createTables(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS KhoaDaoTao (
        makhoa TEXT PRIMARY KEY,
        tenkhoa TEXT NOT NULL,
        sdt TEXT,
        email TEXT,
        website TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS LopChuyenNganh (
        malop TEXT PRIMARY KEY,
        tenlop TEXT NOT NULL,
        siso INTEGER DEFAULT 0,
        hedaotao TEXT NOT NULL,
        nienkhoa TEXT NOT NULL,
        makhoa TEXT NOT NULL,
        FOREIGN KEY (makhoa) REFERENCES KhoaDaoTao(makhoa)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS SinhVien (
        msv TEXT PRIMARY KEY,
        hodem TEXT NOT NULL,
        ten TEXT NOT NULL,
        ngaysinh TEXT NOT NULL,
        gioitinh TEXT NOT NULL,
        malop TEXT NOT NULL,
        FOREIGN KEY (malop) REFERENCES LopChuyenNganh(malop)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS HocPhan (
        mahocphan TEXT PRIMARY KEY,
        tenhocphan TEXT NOT NULL,
        tinchi INTEGER NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS DiemHocPhan (
        mahocphan TEXT NOT NULL,
        msv TEXT NOT NULL,
        diem_a REAL,
        diem_b REAL,
        diem_c REAL,
        PRIMARY KEY (mahocphan, msv),
        FOREIGN KEY (mahocphan) REFERENCES HocPhan(mahocphan),
        FOREIGN KEY (msv) REFERENCES SinhVien(msv)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS LopHocPhan (
        mahocphan TEXT NOT NULL,
        malop TEXT NOT NULL,
        hocky TEXT NOT NULL,
        namhoc TEXT NOT NULL,
        PRIMARY KEY (mahocphan, malop),
        FOREIGN KEY (mahocphan) REFERENCES HocPhan(mahocphan),
        FOREIGN KEY (malop) REFERENCES LopChuyenNganh(malop)
      )
    ''');

    db.execute('''
      CREATE TABLE IF NOT EXISTS Auth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        msv TEXT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'sinhvien',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (msv) REFERENCES SinhVien(msv)
      )
    ''');

    // Tạo index để tăng tốc truy vấn
    db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sinhvien_malop ON SinhVien(malop)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_diem_msv ON DiemHocPhan(msv)');
    db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diem_mahocphan ON DiemHocPhan(mahocphan)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_auth_email ON Auth(email)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_auth_msv ON Auth(msv)');

    // Seed admin mặc định nếu chưa có
    _seedDefaultAdmin(db);
  }

  void _seedDefaultAdmin(Database db) {
    final result = db
        .select('SELECT COUNT(*) as count FROM Auth WHERE role = ?', ['admin']);
    if (result.first['count'] as int == 0) {
      final now = DateTime.now().toIso8601String();
      // Password mặc định: admin123 (đã hash với SHA256)
      // Trong thực tế, bạn nên dùng bcrypt
      const hashedPassword =
          '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9';

      db.execute('''
        INSERT INTO Auth (email, password, role, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?)
      ''', ['admin@school.edu.vn', hashedPassword, 'admin', now, now]);
    }
  }

  void close() {
    _database?.dispose();
    _database = null;
  }

  /// Helper method để chuyển ResultSet thành List<Map>
  static List<Map<String, dynamic>> resultSetToList(ResultSet resultSet) {
    return resultSet.map((row) {
      final map = <String, dynamic>{};
      for (final column in resultSet.columnNames) {
        map[column] = row[column];
      }
      return map;
    }).toList();
  }
}
