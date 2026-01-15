import 'package:dart_frog/dart_frog.dart';

/// Middleware chung cho API v1
/// Thêm CORS headers và logging
Handler middleware(Handler handler) {
  return (context) async {
    // Log request
    final request = context.request;
    print('[${DateTime.now()}] ${request.method.value} ${request.uri}');

    // Handle CORS preflight
    if (request.method == HttpMethod.options) {
      return Response(
        headers: _corsHeaders,
      );
    }

    // Xử lý request
    final response = await handler(context);

    // Thêm CORS headers vào response
    return response.copyWith(
      headers: {
        ...response.headers,
        ..._corsHeaders,
      },
    );
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};
