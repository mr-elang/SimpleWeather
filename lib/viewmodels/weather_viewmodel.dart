import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// ViewModel for the Home / Weather Screen following the MVVM pattern.
/// Manages weather state, selected location, favorites, and app theme.
class WeatherViewModel extends ChangeNotifier {
  static const LocationModel _defaultLocation = LocationModel(
    id: 1621177,
    name: 'Yogyakarta',
    country: 'Indonesia',
    admin1: 'DI Yogyakarta',
    latitude: -7.7956,
    longitude: 110.3695,
  );

  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherViewModel(this._apiService, this._storageService);

  LocationModel _selectedLocation = _defaultLocation;
  WeatherModel? _weather;
  List<LocationModel> _favorites = [];
  ThemeMode _themeMode = ThemeMode.dark;
  bool _useFahrenheit = false;
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  ThemeMode get themeMode => _themeMode;
  bool get useFahrenheit => _useFahrenheit;
  String get unitSymbol => _useFahrenheit ? '°F' : '°C';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Converts a Celsius temperature to the currently selected unit.
  int convertTemp(double celsius) {
    final value = _useFahrenheit ? (celsius * 9 / 5) + 32 : celsius;
    return value.round();
  }

  /// Formats a Celsius temperature with the active unit (e.g. `31°C` or `88°F`).
  String formatTemp(double celsius, {bool includeUnit = true}) {
    final value = convertTemp(celsius);
    return includeUnit ? '$value$unitSymbol' : '$value°';
  }

  /// Loads persisted favorites, theme mode, unit preference, and last
  /// selected location, then fetches fresh weather data from Open-Meteo.
  Future<void> init() async {
    _favorites = await _storageService.getFavorites();
    _themeMode = await _storageService.getThemeMode();
    _useFahrenheit = await _storageService.getUseFahrenheit();
    final savedLocation = await _storageService.getLastLocation();
    if (savedLocation != null) {
      _selectedLocation = savedLocation;
    }
    notifyListeners();
    await fetchWeather();
  }

  /// Fetches weather data for [_selectedLocation] from Open-Meteo API.
  Future<void> fetchWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _apiService.fetchWeather(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan tidak terduga saat memuat cuaca.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a new [location], persists it, and fetches its weather.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _storageService.saveLastLocation(location);
    await fetchWeather();
  }

  /// Returns `true` if [location] is currently saved in favorites.
  bool isFavorite(LocationModel location) {
    return _favorites.contains(location);
  }

  /// Adds or removes [location] from favorites and persists the updated list.
  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites = _favorites.where((item) => item != location).toList();
    } else {
      _favorites = [location, ..._favorites];
    }
    notifyListeners();
    await _storageService.saveFavorites(_favorites);
  }

  /// Cycles through Light -> Dark -> System theme modes and persists choice.
  Future<void> cycleThemeMode() async {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    notifyListeners();
    await _storageService.saveThemeMode(_themeMode);
  }

  /// Toggles between Celsius (°C) and Fahrenheit (°F) and persists choice.
  Future<void> toggleTemperatureUnit() async {
    _useFahrenheit = !_useFahrenheit;
    notifyListeners();
    await _storageService.saveUseFahrenheit(_useFahrenheit);
  }
}
