import 'package:dart_frog/dart_frog.dart';



Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'Quản lý Đào tạo API',
      'version': '1.0.0',
      'description': 'API Backend cho hệ thống quản lý đào tạo',
      'endpoints': {
        'auth': '/api/v1/auth',
        'sinhvien': '/api/v1/sinhvien',
        'hocphan': '/api/v1/hocphan',
        'diem': '/api/v1/diem',
        'lop': '/api/v1/lop',
        'khoa': '/api/v1/khoa',
      },
    },
  );
}
