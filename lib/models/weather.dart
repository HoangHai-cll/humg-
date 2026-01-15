class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final DateTime dateTime;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.dateTime,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  int get temperatureCelsius => temperature.round();
}

class WeatherForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String description;

  WeatherForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '01d',
      description: json['weather'][0]['description'] ?? '',
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  int get tempMinCelsius => tempMin.round();
  int get tempMaxCelsius => tempMax.round();
}
