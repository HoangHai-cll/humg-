import 'package:dart_frog/dart_frog.dart';
import '../models/auth.dart';
import '../utils/jwt_helper.dart';
import '../utils/api_response.dart';
import '../repositories/auth_repository.dart';

/// Thông tin user đã xác thực
class AuthenticatedUser {
  final int id;
  final String? msv;
  final String email;
  final UserRole role;

  AuthenticatedUser({
    required this.id,
    this.msv,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isSinhVien => role == UserRole.sinhvien;
}

/// Middleware xác thực JWT
Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ApiResponse.unauthorized(message: 'Token không được cung cấp');
      }

      final token = authHeader.substring(7);
      final payload = JwtHelper.verifyToken(token);

      if (payload == null) {
        return ApiResponse.unauthorized(
            message: 'Token không hợp lệ hoặc đã hết hạn');
      }

      final userId = int.tryParse(payload['sub'] as String? ?? '');
      if (userId == null) {
        return ApiResponse.unauthorized(message: 'Token không hợp lệ');
      }

      // Kiểm tra user còn tồn tại
      final authRepo = AuthRepository();
      final user = authRepo.findById(userId);
      if (user == null) {
        return ApiResponse.unauthorized(message: 'Người dùng không tồn tại');
      }

      final authenticatedUser = AuthenticatedUser(
        id: user.id,
        msv: user.msv,
        email: user.email,
        role: user.role,
      );

      // Thêm user vào context
      final newContext =
          context.provide<AuthenticatedUser>(() => authenticatedUser);

      return handler(newContext);
    };
  };
}

/// Middleware yêu cầu quyền admin
Middleware adminOnly() {
  return (handler) {
    return (context) async {
      final user = context.read<AuthenticatedUser>();

      if (!user.isAdmin) {
        return ApiResponse.forbidden(
            message: 'Chỉ admin mới có quyền truy cập');
      }

      return handler(context);
    };
  };
}

/// Middleware cho phép admin hoặc chính sinh viên đó
Middleware adminOrSelf(String Function(RequestContext) getMsv) {
  return (handler) {
    return (context) async {
      final user = context.read<AuthenticatedUser>();
      final targetMsv = getMsv(context);

      if (!user.isAdmin && user.msv != targetMsv) {
        return ApiResponse.forbidden(
          message: 'Bạn không có quyền truy cập tài nguyên này',
        );
      }

      return handler(context);
    };
  };
}

/// Extension để lấy user từ context
extension RequestContextExtension on RequestContext {
  AuthenticatedUser get currentUser => read<AuthenticatedUser>();

  bool get isAdmin => currentUser.isAdmin;

  String? get currentMsv => currentUser.msv;
}
