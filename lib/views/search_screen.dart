import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/location_tile.dart';
import '../widgets/weather_skeleton.dart';

/// Search / Location Screen allowing users to search cities via Open-Meteo
/// Geocoding API, select a city, and manage favorite locations & history.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<SearchViewModel>().clearSearch();
      setState(() {});
      return;
    }
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchViewModel>().searchCities(value);
      }
    });
  }

  Future<void> _selectCity(LocationModel location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.addToHistory(location);
    await weatherVm.selectLocation(location);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    onSubmitted: (value) => searchVm.searchCities(value),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kota (mis. Jakarta, Tokyo)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              tooltip: 'Bersihkan',
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _controller.clear();
                                searchVm.clearSearch();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: searchVm.hasSearched
                      ? _buildSearchResults(context, searchVm, weatherVm)
                      : _buildSavedLocations(context, searchVm, weatherVm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    if (searchVm.isLoading) {
      return const SearchSkeleton();
    }

    if (searchVm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                searchVm.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => searchVm.searchCities(_controller.text),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (searchVm.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Kota "${searchVm.query}" tidak ditemukan.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Coba periksa ejaan atau gunakan nama kota lain.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: searchVm.searchResults.length,
      itemBuilder: (context, index) {
        final city = searchVm.searchResults[index];
        return LocationTile(
          location: city,
          isFavorite: weatherVm.isFavorite(city),
          onTap: () => _selectCity(city),
          onToggleFavorite: () => weatherVm.toggleFavorite(city),
        );
      },
    );
  }

  Widget _buildSavedLocations(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    final favorites = weatherVm.favorites;
    final history = searchVm.searchHistory;

    if (favorites.isEmpty && history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.travel_explore_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                'Cari Kota di Seluruh Dunia',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Ketik nama kota di atas untuk melihat informasi cuaca atau menyimpannya sebagai favorit.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Lokasi Favorit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...favorites.map(
            (city) => LocationTile(
              location: city,
              isFavorite: true,
              onTap: () => _selectCity(city),
              onToggleFavorite: () => weatherVm.toggleFavorite(city),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Pencarian',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: searchVm.clearHistory,
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
          ...history.map(
            (city) => LocationTile(
              location: city,
              isFavorite: weatherVm.isFavorite(city),
              onTap: () => _selectCity(city),
              onToggleFavorite: () => weatherVm.toggleFavorite(city),
              onDelete: () => searchVm.removeFromHistory(city),
            ),
          ),
        ],
      ],
    );
  }
}
