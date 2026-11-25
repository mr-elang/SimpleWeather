import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// ViewModel for the Search / Location Screen following the MVVM pattern.
/// Handles city search via Open-Meteo Geocoding API and persisted search history.
class SearchViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  SearchViewModel(this._apiService, this._storageService);

  List<LocationModel> _searchResults = [];
  List<LocationModel> _searchHistory = [];
  String _query = '';
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  /// Loads persisted search history from local storage.
  Future<void> init() async {
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Queries Open-Meteo Geocoding API for cities matching [input].
  Future<void> searchCities(String input) async {
    _query = input.trim();
    if (_query.isEmpty) {
      clearSearch();
      return;
    }

    _isLoading = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchLocations(_query);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _searchResults = [];
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat mencari kota.';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the active search state and returns to the default view.
  void clearSearch() {
    _query = '';
    _searchResults = [];
    _hasSearched = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Records a selected [location] at the top of search history.
  Future<void> addToHistory(LocationModel location) async {
    _searchHistory = [
      location,
      ..._searchHistory.where((item) => item != location),
    ];
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }
    notifyListeners();
    await _storageService.saveSearchHistory(_searchHistory);
  }

  /// Removes a single [location] from search history.
  Future<void> removeFromHistory(LocationModel location) async {
    _searchHistory = _searchHistory.where((item) => item != location).toList();
    notifyListeners();
    await _storageService.saveSearchHistory(_searchHistory);
  }

  /// Clears all persisted search history.
  Future<void> clearHistory() async {
    _searchHistory = [];
    notifyListeners();
    await _storageService.saveSearchHistory(_searchHistory);
  }
}
