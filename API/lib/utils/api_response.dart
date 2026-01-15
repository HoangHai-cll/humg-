import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

class ApiResponse {
  /// Trả về response thành công với data
  static Response success({
    dynamic data,
    String message = 'Success',
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data,
      },
    );
  }

  /// Trả về response thành công khi tạo mới
  static Response created({
    dynamic data,
    String message = 'Created successfully',
  }) {
    return success(data: data, message: message, statusCode: 201);
  }

  /// Trả về response lỗi
  static Response error({
    String message = 'An error occurred',
    int statusCode = 400,
    dynamic errors,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Trả về lỗi 404 Not Found
  static Response notFound({String message = 'Resource not found'}) {
    return error(message: message, statusCode: 404);
  }

  /// Trả về lỗi 401 Unauthorized
  static Response unauthorized({String message = 'Unauthorized'}) {
    return error(message: message, statusCode: 401);
  }

  /// Trả về lỗi 403 Forbidden
  static Response forbidden({String message = 'Access denied'}) {
    return error(message: message, statusCode: 403);
  }

  /// Trả về lỗi 422 Validation Error
  static Response validationError({
    String message = 'Validation failed',
    Map<String, dynamic>? errors,
  }) {
    return error(message: message, statusCode: 422, errors: errors);
  }

  /// Trả về lỗi 500 Internal Server Error
  static Response serverError({String message = 'Internal server error'}) {
    return error(message: message, statusCode: 500);
  }

  /// Trả về response phân trang
  static Response paginated({
    required List<dynamic> data,
    required int page,
    required int perPage,
    required int total,
    String message = 'Success',
  }) {
    final totalPages = (total / perPage).ceil();

    return Response.json(
      body: {
        'success': true,
        'message': message,
        'data': data,
        'pagination': {
          'page': page,
          'per_page': perPage,
          'total': total,
          'total_pages': totalPages,
          'has_next': page < totalPages,
          'has_previous': page > 1,
        },
      },
    );
  }
}

/// Extension để parse JSON body từ request
extension RequestExtension on Request {
  Future<Map<String, dynamic>> jsonBody() async {
    final body = await this.body();
    if (body.isEmpty) return {};
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
