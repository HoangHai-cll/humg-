class AppConstants {
  // API URLs
  static const String baseUrl =
      'http://localhost:8080/api/v1'; 

  // OpenWeather API
  static const String weatherApiKey =
      'b4e2fd52e42c4f4f6cec3264bcbc255c'; // Thay bằng API key của bạn
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String savedPasswordKey = 'saved_password';
}

class AppColors {
  static const int primaryBlue = 0xFF2196F3;
  static const int lightBlue = 0xFF64B5F6;
  static const int darkBlue = 0xFF1565C0;
  static const int green = 0xFF4CAF50;
  static const int white = 0xFFFFFFFF;
  static const int grey = 0xFF9E9E9E;
  static const int lightGrey = 0xFFF5F5F5;
  static const int darkGrey = 0xFF616161;
  static const int error = 0xFFE53935;
}
