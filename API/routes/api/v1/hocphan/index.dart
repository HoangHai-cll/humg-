import 'package:dart_frog/dart_frog.dart';
import 'package:quanlydaotao_api_backend/repositories/lop_hoc_phan_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final params = request.uri.queryParameters;

  final msv = params['msv'];
  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final perPage = int.tryParse(params['per_page'] ?? '20') ?? 20;

  if (msv == null || msv.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'success': false,
        'message': 'Thiếu mã sinh viên (msv)',
      },
    );
  }

  final repo = LopHocPhanRepository();
  final allData = await repo.getHocPhanChiTietByMsv(msv);

  final total = allData.length;
  final start = (page - 1) * perPage;
  final end = (start + perPage > total) ? total : start + perPage;
  final data = (start < total) ? allData.sublist(start, end) : [];

  return Response.json(
    body: {
      'success': true,
      'data': data,
      'pagination': {
        'page': page,
        'per_page': perPage,
        'total': total,
        'total_pages': (total / perPage).ceil(),
      },
    },
  );
}
