import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../utils/constants.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl;

  WeatherService({
    this.apiKey = AppConstants.weatherApiKey,
    this.baseUrl = AppConstants.weatherBaseUrl,
  });

  /// Lấy thời tiết hiện tại theo tọa độ
  Future<Weather> getCurrentWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Không thể lấy dữ liệu thời tiết');
    }
  }

  /// Lấy thời tiết theo tên thành phố
  Future<Weather> getWeatherByCity(String cityName) async {
    final url = Uri.parse(
      '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric&lang=vi',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Không tìm thấy thành phố');
    }
  }

  /// Lấy dự báo 5 ngày
  Future<List<WeatherForecast>> getForecast(double lat, double lon) async {
    final url = Uri.parse(
      '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=vi',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List;

      // Lọc lấy 1 forecast mỗi ngày (12:00)
      final Map<String, WeatherForecast> dailyForecasts = {};

      for (var item in list) {
        final forecast = WeatherForecast.fromJson(item);
        final dateKey =
            '${forecast.date.year}-${forecast.date.month}-${forecast.date.day}';

        // Chỉ lấy forecast đầu tiên của mỗi ngày hoặc lúc 12:00
        if (!dailyForecasts.containsKey(dateKey) || forecast.date.hour == 12) {
          dailyForecasts[dateKey] = forecast;
        }
      }

      return dailyForecasts.values.take(5).toList();
    } else {
      throw Exception('Không thể lấy dự báo thời tiết');
    }
  }

  /// Lấy icon thời tiết phù hợp
  static String getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '☁️';
    }
  }
}
