import 'dart:convert';

class LopChuyenNganh {
  final String malop;
  final String tenlop;
  final int siso;
  final String hedaotao;
  final String nienkhoa;
  final String makhoa;

  LopChuyenNganh({
    required this.malop,
    required this.tenlop,
    required this.siso,
    required this.hedaotao,
    required this.nienkhoa,
    required this.makhoa,
  });

  factory LopChuyenNganh.fromMap(Map<String, dynamic> map) {
    return LopChuyenNganh(
      malop: map['malop'] as String,
      tenlop: map['tenlop'] as String,
      siso: map['siso'] as int,
      hedaotao: map['hedaotao'] as String,
      nienkhoa: map['nienkhoa'] as String,
      makhoa: map['makhoa'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'malop': malop,
      'tenlop': tenlop,
      'siso': siso,
      'hedaotao': hedaotao,
      'nienkhoa': nienkhoa,
      'makhoa': makhoa,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory LopChuyenNganh.fromJson(String source) =>
      LopChuyenNganh.fromMap(jsonDecode(source) as Map<String, dynamic>);

  LopChuyenNganh copyWith({
    String? malop,
    String? tenlop,
    int? siso,
    String? hedaotao,
    String? nienkhoa,
    String? makhoa,
  }) {
    return LopChuyenNganh(
      malop: malop ?? this.malop,
      tenlop: tenlop ?? this.tenlop,
      siso: siso ?? this.siso,
      hedaotao: hedaotao ?? this.hedaotao,
      nienkhoa: nienkhoa ?? this.nienkhoa,
      makhoa: makhoa ?? this.makhoa,
    );
  }

  @override
  String toString() {
    return 'LopChuyenNganh(malop: $malop, tenlop: $tenlop, siso: $siso, hedaotao: $hedaotao, nienkhoa: $nienkhoa, makhoa: $makhoa)';
  }
}
