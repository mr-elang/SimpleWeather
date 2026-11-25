import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Custom exception for API and network failures.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Service responsible for communicating with Open-Meteo REST APIs
/// (Weather Forecast API and Geocoding API) using HTTP GET.
class WeatherApiService {
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches current weather and 7-day daily forecast for the given coordinates.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code,precipitation_probability',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data cuaca (Status ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['error'] == true) {
        throw ApiException(
          decoded['reason'] as String? ?? 'Terjadi kesalahan dari server Open-Meteo.',
        );
      }

      return WeatherModel.fromJson(decoded);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        'Tidak dapat terhubung ke server cuaca. Periksa koneksi internet Anda.',
      );
    }
  }

  /// Searches cities by [query] using Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mencari lokasi (Status ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return [];
      }

      return results
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw const ApiException(
        'Gagal mencari lokasi. Periksa koneksi internet Anda.',
      );
    }
  }
}
