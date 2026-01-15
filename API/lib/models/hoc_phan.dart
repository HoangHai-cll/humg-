import 'dart:convert';

class HocPhan {
  final String mahocphan;
  final String tenhocphan;
  final int tinchi;

  HocPhan({
    required this.mahocphan,
    required this.tenhocphan,
    required this.tinchi,
  });

  factory HocPhan.fromMap(Map<String, dynamic> map) {
    return HocPhan(
      mahocphan: map['mahocphan'] as String,
      tenhocphan: map['tenhocphan'] as String,
      tinchi: map['tinchi'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mahocphan': mahocphan,
      'tenhocphan': tenhocphan,
      'tinchi': tinchi,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory HocPhan.fromJson(String source) =>
      HocPhan.fromMap(jsonDecode(source) as Map<String, dynamic>);

  HocPhan copyWith({
    String? mahocphan,
    String? tenhocphan,
    int? tinchi,
  }) {
    return HocPhan(
      mahocphan: mahocphan ?? this.mahocphan,
      tenhocphan: tenhocphan ?? this.tenhocphan,
      tinchi: tinchi ?? this.tinchi,
    );
  }

  @override
  String toString() {
    return 'HocPhan(mahocphan: $mahocphan, tenhocphan: $tenhocphan, tinchi: $tinchi)';
  }
}
