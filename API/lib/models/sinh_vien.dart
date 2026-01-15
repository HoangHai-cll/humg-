import 'dart:convert';

class SinhVien {
  final String msv;
  final String hodem;
  final String ten;
  final DateTime ngaysinh;
  final String gioitinh;
  final String malop;

  SinhVien({
    required this.msv,
    required this.hodem,
    required this.ten,
    required this.ngaysinh,
    required this.gioitinh,
    required this.malop,
  });

  factory SinhVien.fromMap(Map<String, dynamic> map) {
    return SinhVien(
      msv: map['msv'] as String,
      hodem: map['hodem'] as String,
      ten: map['ten'] as String,
      ngaysinh: DateTime.parse(map['ngaysinh'] as String),
      gioitinh: map['gioitinh'] as String,
      malop: map['malop'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'msv': msv,
      'hodem': hodem,
      'ten': ten,
      'ngaysinh': ngaysinh.toIso8601String().split('T')[0],
      'gioitinh': gioitinh,
      'malop': malop,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory SinhVien.fromJson(String source) =>
      SinhVien.fromMap(jsonDecode(source) as Map<String, dynamic>);

  SinhVien copyWith({
    String? msv,
    String? hodem,
    String? ten,
    DateTime? ngaysinh,
    String? gioitinh,
    String? malop,
  }) {
    return SinhVien(
      msv: msv ?? this.msv,
      hodem: hodem ?? this.hodem,
      ten: ten ?? this.ten,
      ngaysinh: ngaysinh ?? this.ngaysinh,
      gioitinh: gioitinh ?? this.gioitinh,
      malop: malop ?? this.malop,
    );
  }

  String get hoTen => '$hodem $ten';

  @override
  String toString() {
    return 'SinhVien(msv: $msv, hodem: $hodem, ten: $ten, ngaysinh: $ngaysinh, gioitinh: $gioitinh, malop: $malop)';
  }
}
