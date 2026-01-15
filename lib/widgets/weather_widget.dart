import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  @override
  void initState() {
    super.initState();
    // Load weather khi widget được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (weatherProvider.status == WeatherStatus.error) {
          return _buildErrorWidget(weatherProvider.errorMessage);
        }

        final weather = weatherProvider.currentWeather;
        final forecasts = weatherProvider.forecasts;

        if (weather == null) {
          return _buildLoadingWidget();
        }

        return _buildWeatherContent(weather, forecasts);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget(String? message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 50),
          const SizedBox(height: 10),
          Text(
            message ?? 'Không thể tải thời tiết',
            style: const TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () => context.read<WeatherProvider>().refresh(),
            child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(weather, List forecasts) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'vi_VN');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
          child: Column(
            children: [
              // Weather Icon
              _buildWeatherIcon(weather.icon),

              // Temperature
              Text(
                '${weather.temperatureCelsius}°',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),

              // Date
              Text(
                dateFormat.format(now),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Forecast
              if (forecasts.isNotEmpty) _buildForecastRow(forecasts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String iconCode) {
    final icon = WeatherService.getWeatherIcon(iconCode);

    // Nếu icon là emoji
    if (icon.length <= 2) {
      return Text(icon, style: const TextStyle(fontSize: 60));
    }

    // Sử dụng icon mặc định
    return const Icon(Icons.cloud, size: 60, color: Colors.white);
  }

  Widget _buildForecastRow(List forecasts) {
    final dayFormat = DateFormat('EEEE', 'vi_VN');

    // Lấy tối đa 4 ngày tiếp theo
    final nextDays = forecasts.take(4).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: nextDays.map((forecast) {
        String dayName = dayFormat.format(forecast.date);
        // Viết hoa chữ cái đầu
        dayName = dayName[0].toUpperCase() + dayName.substring(1);
        // Rút gọn
        if (dayName.length > 6) {
          dayName = dayName.substring(0, 6);
        }

        return Column(
          children: [
            Text(
              dayName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 5),
            _buildSmallWeatherIcon(forecast.icon),
            const SizedBox(height: 5),
            Text(
              '${forecast.tempMinCelsius}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSmallWeatherIcon(String iconCode) {
    IconData icon;

    if (iconCode.contains('01')) {
      icon = Icons.wb_sunny;
    } else if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04')) {
      icon = Icons.cloud;
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      icon = Icons.grain; // Rain
    } else if (iconCode.contains('11')) {
      icon = Icons.flash_on; // Thunderstorm
    } else if (iconCode.contains('13')) {
      icon = Icons.ac_unit; // Snow
    } else {
      icon = Icons.cloud;
    }

    return Icon(icon, color: Colors.white70, size: 24);
  }
}
