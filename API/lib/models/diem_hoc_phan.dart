import 'dart:convert';

class DiemHocPhan {
  final String mahocphan;
  final String msv;
  final double? diemA;
  final double? diemB;
  final double? diemC;

  DiemHocPhan({
    required this.mahocphan,
    required this.msv,
    this.diemA,
    this.diemB,
    this.diemC,
  });

  factory DiemHocPhan.fromMap(Map<String, dynamic> map) {
    return DiemHocPhan(
      mahocphan: map['mahocphan'] as String,
      msv: map['msv'] as String,
      diemA: (map['diem_a'] as num?)?.toDouble(),
      diemB: (map['diem_b'] as num?)?.toDouble(),
      diemC: (map['diem_c'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mahocphan': mahocphan,
      'msv': msv,
      'diem_a': diemA,
      'diem_b': diemB,
      'diem_c': diemC,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory DiemHocPhan.fromJson(String source) =>
      DiemHocPhan.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Tính điểm tổng kết theo công thức: 0.1*A + 0.4*B + 0.5*C
  double? get diemTongKet {
    if (diemA == null || diemB == null || diemC == null) return null;
    return 0.1 * diemA! + 0.4 * diemB! + 0.5 * diemC!;
  }

  /// Xếp loại điểm chữ
  String? get diemChu {
    final dtk = diemTongKet;
    if (dtk == null) return null;
    if (dtk >= 9.0) return 'A+';
    if (dtk >= 8.5) return 'A';
    if (dtk >= 8.0) return 'B+';
    if (dtk >= 7.0) return 'B';
    if (dtk >= 6.5) return 'C+';
    if (dtk >= 5.5) return 'C';
    if (dtk >= 5.0) return 'D+';
    if (dtk >= 4.0) return 'D';
    return 'F';
  }

  /// Điểm hệ 4
  double? get diemHe4 {
    final dtk = diemTongKet;
    if (dtk == null) return null;
    if (dtk >= 9.0) return 4.0;
    if (dtk >= 8.5) return 3.7;
    if (dtk >= 8.0) return 3.5;
    if (dtk >= 7.0) return 3.0;
    if (dtk >= 6.5) return 2.5;
    if (dtk >= 5.5) return 2.0;
    if (dtk >= 5.0) return 1.5;
    if (dtk >= 4.0) return 1.0;
    return 0.0;
  }

  DiemHocPhan copyWith({
    String? mahocphan,
    String? msv,
    double? diemA,
    double? diemB,
    double? diemC,
  }) {
    return DiemHocPhan(
      mahocphan: mahocphan ?? this.mahocphan,
      msv: msv ?? this.msv,
      diemA: diemA ?? this.diemA,
      diemB: diemB ?? this.diemB,
      diemC: diemC ?? this.diemC,
    );
  }

  Map<String, dynamic> toMapWithCalculated() {
    return {
      ...toMap(),
      'diem_tong_ket': diemTongKet,
      'diem_chu': diemChu,
      'diem_he_4': diemHe4,
    };
  }

  @override
  String toString() {
    return 'DiemHocPhan(mahocphan: $mahocphan, msv: $msv, diemA: $diemA, diemB: $diemB, diemC: $diemC)';
  }
}
