import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage;

  AuthService({this.baseUrl = AppConstants.baseUrl})
    : _secureStorage = const FlutterSecureStorage();

  /// Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']['access_token'];
      final userData = data['data']['user'];

      // Lưu token
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);

      // Lưu user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, json.encode(userData));

      return {'success': true, 'token': token, 'user': User.fromJson(userData)};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Đăng nhập thất bại',
      };
    }
  }

  /// Đăng ký
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? msv,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final body = {'email': email, 'password': password};

    if (msv != null && msv.isNotEmpty) {
      body['msv'] = msv;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      final token = data['data']['access_token'];
      final userData = data['data']['user'];

      await _secureStorage.write(key: AppConstants.tokenKey, value: token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userKey, json.encode(userData));

      return {'success': true, 'token': token, 'user': User.fromJson(userData)};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Đăng ký thất bại',
        'errors': data['errors'],
      };
    }
  }

  /// Quên mật khẩu (giả lập - trong thực tế cần gửi email)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    // Giả lập gửi email reset password
    await Future.delayed(const Duration(seconds: 2));

    // Trong thực tế, bạn sẽ gọi API
    // final url = Uri.parse('$baseUrl/auth/forgot-password');
    // final response = await http.post(...);

    return {
      'success': true,
      'message': 'Đã gửi email hướng dẫn đặt lại mật khẩu',
    };
  }

  /// Lấy thông tin user hiện tại
  Future<User?> getCurrentUser() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userKey);

    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }

    // Nếu không có trong cache, gọi API
    try {
      final url = Uri.parse('$baseUrl/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await prefs.setString(
            AppConstants.userKey,
            json.encode(data['data']),
          );
          return User.fromJson(data['data']);
        }
      }
    } catch (e) {
      // Token hết hạn hoặc không hợp lệ
    }

    return null;
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
  }

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }

  /// Lấy token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  /// Lưu thông tin remember me
  Future<void> saveRememberMe(
    bool remember,
    String email,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.rememberMeKey, remember);

    if (remember) {
      await _secureStorage.write(key: AppConstants.savedEmailKey, value: email);
      await _secureStorage.write(
        key: AppConstants.savedPasswordKey,
        value: password,
      );
    } else {
      await _secureStorage.delete(key: AppConstants.savedEmailKey);
      await _secureStorage.delete(key: AppConstants.savedPasswordKey);
    }
  }

  /// Lấy thông tin remember me
  Future<Map<String, dynamic>> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(AppConstants.rememberMeKey) ?? false;

    if (remember) {
      final email = await _secureStorage.read(key: AppConstants.savedEmailKey);
      final password = await _secureStorage.read(
        key: AppConstants.savedPasswordKey,
      );
      return {
        'remember': true,
        'email': email ?? '',
        'password': password ?? '',
      };
    }

    return {'remember': false, 'email': '', 'password': ''};
  }
}
