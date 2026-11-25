import 'package:flutter_test/flutter_test.dart';
import 'package:simple_weather/models/location_model.dart';
import 'package:simple_weather/models/weather_model.dart';

void main() {
  test('LocationModel serializes and deserializes correctly', () {
    final json = {
      'id': 1621177,
      'name': 'Yogyakarta',
      'country': 'Indonesia',
      'admin1': 'DI Yogyakarta',
      'latitude': -7.7956,
      'longitude': 110.3695,
    };

    final location = LocationModel.fromJson(json);
    expect(location.name, 'Yogyakarta');
    expect(location.subtitle, 'DI Yogyakarta, Indonesia');
    expect(location.toJson()['latitude'], -7.7956);
  });

  test('WeatherModel parses Open-Meteo current and daily JSON', () {
    final json = {
      'latitude': -7.75,
      'longitude': 110.375,
      'timezone': 'Asia/Jakarta',
      'current': {
        'time': '2026-11-25T12:00',
        'temperature_2m': 31.4,
        'relative_humidity_2m': 68,
        'apparent_temperature': 35.2,
        'precipitation': 0.2,
        'weather_code': 2,
        'wind_speed_10m': 12.5,
      },
      'hourly': {
        'time': ['2026-11-25T11:00', '2026-11-25T12:00', '2026-11-25T13:00'],
        'temperature_2m': [30.0, 31.4, 32.1],
        'weather_code': [1, 2, 3],
        'precipitation_probability': [10, 20, 45],
      },
      'daily': {
        'time': ['2026-11-25', '2026-11-26'],
        'weather_code': [2, 61],
        'temperature_2m_max': [33.0, 31.5],
        'temperature_2m_min': [24.0, 23.5],
        'precipitation_probability_max': [40, 80],
      },
    };

    final weather = WeatherModel.fromJson(json);
    expect(weather.current.temperature2m, 31.4);
    expect(weather.current.relativeHumidity2m, 68);
    expect(weather.current.weatherInfo.description, 'Berawan Sebagian');
    expect(weather.hourly.length, 2);
    expect(weather.hourly.first.temperature2m, 31.4);
    expect(weather.hourly.last.precipitationProbability, 45);
    expect(weather.daily.length, 2);
    expect(weather.daily[1].weatherInfo.description, 'Hujan Ringan');
    expect(weather.daily[1].precipitationProbabilityMax, 80);
  });
}
