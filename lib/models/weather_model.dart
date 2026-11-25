import 'package:flutter/material.dart';

/// Helper class mapping WMO weather codes from Open-Meteo to Indonesian
/// descriptions, Material icons, and accent colors.
class WeatherCodeInfo {
  final String description;
  final IconData icon;
  final Color accentColor;

  const WeatherCodeInfo({
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  static WeatherCodeInfo fromCode(int code) {
    switch (code) {
      case 0:
        return const WeatherCodeInfo(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          accentColor: Color(0xFFF59E0B),
        );
      case 1:
        return const WeatherCodeInfo(
          description: 'Cerah Berawan',
          icon: Icons.wb_sunny_outlined,
          accentColor: Color(0xFFFBBF24),
        );
      case 2:
        return const WeatherCodeInfo(
          description: 'Berawan Sebagian',
          icon: Icons.cloud_queue_rounded,
          accentColor: Color(0xFF60A5FA),
        );
      case 3:
        return const WeatherCodeInfo(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
          accentColor: Color(0xFF64748B),
        );
      case 45:
      case 48:
        return const WeatherCodeInfo(
          description: 'Berkabut',
          icon: Icons.foggy,
          accentColor: Color(0xFF94A3B8),
        );
      case 51:
      case 53:
      case 55:
        return const WeatherCodeInfo(
          description: 'Gerimis',
          icon: Icons.grain_rounded,
          accentColor: Color(0xFF38BDF8),
        );
      case 56:
      case 57:
        return const WeatherCodeInfo(
          description: 'Gerimis Beku',
          icon: Icons.ac_unit_rounded,
          accentColor: Color(0xFF0EA5E9),
        );
      case 61:
        return const WeatherCodeInfo(
          description: 'Hujan Ringan',
          icon: Icons.water_drop_outlined,
          accentColor: Color(0xFF3B82F6),
        );
      case 63:
        return const WeatherCodeInfo(
          description: 'Hujan Sedang',
          icon: Icons.water_drop_rounded,
          accentColor: Color(0xFF2563EB),
        );
      case 65:
        return const WeatherCodeInfo(
          description: 'Hujan Lebat',
          icon: Icons.umbrella_rounded,
          accentColor: Color(0xFF1D4ED8),
        );
      case 66:
      case 67:
        return const WeatherCodeInfo(
          description: 'Hujan Beku',
          icon: Icons.ac_unit_rounded,
          accentColor: Color(0xFF0284C7),
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherCodeInfo(
          description: 'Salju',
          icon: Icons.ac_unit_rounded,
          accentColor: Color(0xFF7DD3FC),
        );
      case 80:
      case 81:
      case 82:
        return const WeatherCodeInfo(
          description: 'Hujan Deras',
          icon: Icons.beach_access_rounded,
          accentColor: Color(0xFF1E40AF),
        );
      case 85:
      case 86:
        return const WeatherCodeInfo(
          description: 'Hujan Salju',
          icon: Icons.cloudy_snowing,
          accentColor: Color(0xFF38BDF8),
        );
      case 95:
        return const WeatherCodeInfo(
          description: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          accentColor: Color(0xFF7C3AED),
        );
      case 96:
      case 99:
        return const WeatherCodeInfo(
          description: 'Badai Petir & Es',
          icon: Icons.flash_on_rounded,
          accentColor: Color(0xFF6D28D9),
        );
      default:
        return const WeatherCodeInfo(
          description: 'Tidak Diketahui',
          icon: Icons.help_outline_rounded,
          accentColor: Color(0xFF64748B),
        );
    }
  }
}

/// Current weather conditions from Open-Meteo `current` object.
class CurrentWeather {
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final DateTime? time;

  const CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      time: json['time'] != null ? DateTime.tryParse(json['time'] as String) : null,
    );
  }

  WeatherCodeInfo get weatherInfo => WeatherCodeInfo.fromCode(weatherCode);
}

/// Single hour forecast item derived from Open-Meteo `hourly` arrays.
class HourlyForecast {
  final DateTime time;
  final double temperature2m;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyForecast({
    required this.time,
    required this.temperature2m,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  WeatherCodeInfo get weatherInfo => WeatherCodeInfo.fromCode(weatherCode);
}

/// Single day forecast item derived from Open-Meteo `daily` arrays.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperature2mMax;
  final double temperature2mMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });

  WeatherCodeInfo get weatherInfo => WeatherCodeInfo.fromCode(weatherCode);
}

/// Complete weather response model combining current conditions, hourly,
/// and daily forecasts.
class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final DateTime fetchedAt;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.fetchedAt,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final current = CurrentWeather.fromJson(currentJson);
    final dailyJson = json['daily'] as Map<String, dynamic>;

    final times = (dailyJson['time'] as List<dynamic>).cast<String>();
    final codes = (dailyJson['weather_code'] as List<dynamic>?)
            ?.map((e) => (e as num?)?.toInt() ?? 0)
            .toList() ??
        List<int>.filled(times.length, 0);
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final precipProbs = (dailyJson['precipitation_probability_max'] as List<dynamic>)
        .map((e) => (e as num?)?.toInt() ?? 0)
        .toList();

    final dailyList = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      dailyList.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          weatherCode: i < codes.length ? codes[i] : 0,
          temperature2mMax: maxTemps[i],
          temperature2mMin: minTemps[i],
          precipitationProbabilityMax: i < precipProbs.length ? precipProbs[i] : 0,
        ),
      );
    }

    final hourlyList = _parseHourly(
      json['hourly'] as Map<String, dynamic>?,
      current.time,
    );

    return WeatherModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? 'auto',
      fetchedAt: DateTime.now(),
      current: current,
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  static List<HourlyForecast> _parseHourly(
    Map<String, dynamic>? hourlyJson,
    DateTime? currentTime,
  ) {
    if (hourlyJson == null) return const [];

    final times = (hourlyJson['time'] as List<dynamic>?)?.cast<String>() ?? [];
    final temps = (hourlyJson['temperature_2m'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];
    final codes = (hourlyJson['weather_code'] as List<dynamic>?)
            ?.map((e) => (e as num?)?.toInt() ?? 0)
            .toList() ??
        [];
    final probs = (hourlyJson['precipitation_probability'] as List<dynamic>?)
            ?.map((e) => (e as num?)?.toInt() ?? 0)
            .toList() ??
        [];

    final anchor = currentTime != null
        ? DateTime(currentTime.year, currentTime.month, currentTime.day, currentTime.hour)
        : null;

    final result = <HourlyForecast>[];
    for (var i = 0; i < times.length && i < temps.length; i++) {
      final parsedTime = DateTime.tryParse(times[i]);
      if (parsedTime == null) continue;
      if (anchor != null && parsedTime.isBefore(anchor)) continue;

      result.add(
        HourlyForecast(
          time: parsedTime,
          temperature2m: temps[i],
          weatherCode: i < codes.length ? codes[i] : 0,
          precipitationProbability: i < probs.length ? probs[i] : 0,
        ),
      );
      if (result.length >= 24) break;
    }

    return result;
  }
}
