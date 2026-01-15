import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _rememberMe = false;
  String _savedEmail = '';
  String _savedPassword = '';

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get rememberMe => _rememberMe;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  /// Khởi tạo - kiểm tra trạng thái đăng nhập
  Future<void> init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // Load remember me
      final rememberData = await _authService.getRememberMe();
      _rememberMe = rememberData['remember'] ?? false;
      _savedEmail = rememberData['email'] ?? '';
      _savedPassword = rememberData['password'] ?? '';

      // Kiểm tra user đã đăng nhập
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  /// Đăng nhập
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        _user = result['user'];
        _status = AuthStatus.authenticated;

        // Lưu remember me
        await _authService.saveRememberMe(_rememberMe, email, password);

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối. Vui lòng thử lại.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Đăng ký
  Future<bool> register({
    required String email,
    required String password,
    String? msv,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        msv: msv,
      );

      if (result['success'] == true) {
        _user = result['user'];
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối. Vui lòng thử lại.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Quên mật khẩu
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      return await _authService.forgotPassword(email);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối. Vui lòng thử lại.'};
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Set remember me
  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }


  
}
