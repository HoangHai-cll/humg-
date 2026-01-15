import 'dart:convert';

class KhoaDaoTao {
  final String makhoa;
  final String tenkhoa;
  final String? sdt;
  final String? email;
  final String? website;

  KhoaDaoTao({
    required this.makhoa,
    required this.tenkhoa,
    this.sdt,
    this.email,
    this.website,
  });

  factory KhoaDaoTao.fromMap(Map<String, dynamic> map) {
    return KhoaDaoTao(
      makhoa: map['makhoa'] as String,
      tenkhoa: map['tenkhoa'] as String,
      sdt: map['sdt'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'makhoa': makhoa,
      'tenkhoa': tenkhoa,
      'sdt': sdt,
      'email': email,
      'website': website,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory KhoaDaoTao.fromJson(String source) =>
      KhoaDaoTao.fromMap(jsonDecode(source) as Map<String, dynamic>);

  KhoaDaoTao copyWith({
    String? makhoa,
    String? tenkhoa,
    String? sdt,
    String? email,
    String? website,
  }) {
    return KhoaDaoTao(
      makhoa: makhoa ?? this.makhoa,
      tenkhoa: tenkhoa ?? this.tenkhoa,
      sdt: sdt ?? this.sdt,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }

  @override
  String toString() {
    return 'KhoaDaoTao(makhoa: $makhoa, tenkhoa: $tenkhoa, sdt: $sdt, email: $email, website: $website)';
  }
}
