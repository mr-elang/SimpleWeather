import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// Service that persists favorite locations, search history, last selected
/// location, and theme preference using [SharedPreferences].
class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _historyKey = 'search_history';
  static const String _lastLocationKey = 'last_selected_location';
  static const String _themeModeKey = 'theme_mode';
  static const String _useFahrenheitKey = 'use_fahrenheit';
  static const int _maxHistoryItems = 10;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Loads the list of saved favorite locations.
  Future<List<LocationModel>> getFavorites() async {
    final prefs = await _prefs;
    return _decodeLocationList(prefs.getString(_favoritesKey));
  }

  /// Saves the list of favorite locations.
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await _prefs;
    await prefs.setString(_favoritesKey, _encodeLocationList(favorites));
  }

  /// Loads the search history list.
  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await _prefs;
    return _decodeLocationList(prefs.getString(_historyKey));
  }

  /// Saves the search history list, capped at [_maxHistoryItems].
  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await _prefs;
    final capped = history.take(_maxHistoryItems).toList();
    await prefs.setString(_historyKey, _encodeLocationList(capped));
  }

  /// Loads the last selected location, or `null` if none has been saved.
  Future<LocationModel?> getLastLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Saves the currently selected location so it restores on next app launch.
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  /// Loads the saved [ThemeMode], defaulting to [ThemeMode.dark].
  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final value = prefs.getString(_themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  /// Persists the user's [ThemeMode] preference.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  /// Loads whether temperatures should be displayed in Fahrenheit.
  Future<bool> getUseFahrenheit() async {
    final prefs = await _prefs;
    return prefs.getBool(_useFahrenheitKey) ?? false;
  }

  /// Persists the user's temperature unit preference.
  Future<void> saveUseFahrenheit(bool useFahrenheit) async {
    final prefs = await _prefs;
    await prefs.setBool(_useFahrenheitKey, useFahrenheit);
  }

  List<LocationModel> _decodeLocationList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _encodeLocationList(List<LocationModel> locations) {
    return jsonEncode(locations.map((e) => e.toJson()).toList());
  }
}
