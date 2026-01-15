import 'dart:convert';

class LopHocPhan {
  final String mahocphan;
  final String malop;
  final String hocky;
  final String namhoc;

  LopHocPhan({
    required this.mahocphan,
    required this.malop,
    required this.hocky,
    required this.namhoc,
  });

  factory LopHocPhan.fromMap(Map<String, dynamic> map) {
    return LopHocPhan(
      mahocphan: map['mahocphan'] as String,
      malop: map['malop'] as String,
      hocky: map['hocky'] as String,
      namhoc: map['namhoc'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mahocphan': mahocphan,
      'malop': malop,
      'hocky': hocky,
      'namhoc': namhoc,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory LopHocPhan.fromJson(String source) =>
      LopHocPhan.fromMap(jsonDecode(source) as Map<String, dynamic>);

  LopHocPhan copyWith({
    String? mahocphan,
    String? malop,
    String? hocky,
    String? namhoc,
  }) {
    return LopHocPhan(
      mahocphan: mahocphan ?? this.mahocphan,
      malop: malop ?? this.malop,
      hocky: hocky ?? this.hocky,
      namhoc: namhoc ?? this.namhoc,
    );
  }

  @override
  String toString() {
    return 'LopHocPhan(mahocphan: $mahocphan, malop: $malop, hocky: $hocky, namhoc: $namhoc)';
  }
}
