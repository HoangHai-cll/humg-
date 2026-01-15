import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;

  WeatherStatus _status = WeatherStatus.initial;
  Weather? _currentWeather;
  List<WeatherForecast> _forecasts = [];
  String? _errorMessage;
  Position? _currentPosition;

  WeatherProvider({WeatherService? weatherService})
    : _weatherService = weatherService ?? WeatherService();

  // Getters
  WeatherStatus get status => _status;
  Weather? get currentWeather => _currentWeather;
  List<WeatherForecast> get forecasts => _forecasts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == WeatherStatus.loading;

  /// Lấy vị trí hiện tại và thời tiết
  Future<void> loadWeather() async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      // Kiểm tra permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Nếu không có permission, dùng vị trí mặc định (Hà Nội)
          await _loadWeatherByCoords(21.0285, 105.8542);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Dùng vị trí mặc định
        await _loadWeatherByCoords(21.0285, 105.8542);
        return;
      }

      // Lấy vị trí hiện tại
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      await _loadWeatherByCoords(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    } catch (e) {
      // Fallback to Hanoi
      try {
        await _loadWeatherByCoords(21.0285, 105.8542);
      } catch (e2) {
        _errorMessage = 'Không thể lấy dữ liệu thời tiết';
        _status = WeatherStatus.error;
        notifyListeners();
      }
    }
  }

  /// Load thời tiết theo tọa độ
  Future<void> _loadWeatherByCoords(double lat, double lon) async {
    try {
      _currentWeather = await _weatherService.getCurrentWeather(lat, lon);
      _forecasts = await _weatherService.getForecast(lat, lon);
      _status = WeatherStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể lấy dữ liệu thời tiết';
      _status = WeatherStatus.error;
    }
    notifyListeners();
  }

  /// Load thời tiết theo tên thành phố
  Future<void> loadWeatherByCity(String cityName) async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      _currentWeather = await _weatherService.getWeatherByCity(cityName);
      _status = WeatherStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không tìm thấy thành phố';
      _status = WeatherStatus.error;
    }
    notifyListeners();
  }

  /// Refresh
  Future<void> refresh() async {
    await loadWeather();
  }
}
