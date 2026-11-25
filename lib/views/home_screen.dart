import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/weather_detail_card.dart';
import '../widgets/weather_skeleton.dart';
import 'search_screen.dart';

/// Home / Weather Screen displaying current weather conditions, detailed metrics,
/// favorite city shortcuts, and multi-day forecast from Open-Meteo API.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final theme = Theme.of(context);
    final isFav = vm.isFavorite(vm.selectedLocation);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.selectedLocation.name),
            if (vm.selectedLocation.subtitle.isNotEmpty)
              Text(
                vm.selectedLocation.subtitle,
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: vm.toggleTemperatureUnit,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 40),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              foregroundColor: theme.colorScheme.onSurface,
            ),
            child: Text(
              vm.unitSymbol,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
            icon: Icon(
              isFav ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFav ? Colors.amber : null,
            ),
            onPressed: () => vm.toggleFavorite(vm.selectedLocation),
          ),
          IconButton(
            tooltip: 'Ubah Tema',
            icon: Icon(_themeIcon(vm.themeMode)),
            onPressed: vm.cycleThemeMode,
          ),
          IconButton(
            tooltip: 'Cari Kota',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    if (vm.favorites.isNotEmpty) _FavoritesBar(vm: vm),
                    Expanded(
                      child: _buildBody(context, vm, constraints.maxWidth),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };
  }

  Widget _buildBody(
    BuildContext context,
    WeatherViewModel vm,
    double maxWidth,
  ) {
    if (vm.isLoading) {
      return WeatherSkeleton(maxWidth: maxWidth);
    }

    if (vm.errorMessage != null && vm.weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: vm.fetchWeather,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = vm.weather;
    if (weather == null) {
      return const Center(
        child: Text('Belum ada data cuaca. Pilih kota untuk memulai.'),
      );
    }

    final todayForecast = weather.daily.isNotEmpty ? weather.daily.first : null;
    final gridColumns = maxWidth >= 600 ? 4 : 2;

    return RefreshIndicator(
      onRefresh: vm.fetchWeather,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MaterialBanner(
                content: Text(vm.errorMessage!),
                actions: [
                  TextButton(
                    onPressed: vm.fetchWeather,
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ),
          _HeroWeatherCard(
            weather: weather,
            todayForecast: todayForecast,
            formatTemp: vm.formatTemp,
          ),
          if (weather.hourly.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Prakiraan Per Jam',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            HourlyForecastList(
              hourly: weather.hourly,
              formatTemp: (c) => vm.formatTemp(c, includeUnit: false),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Detail Cuaca Saat Ini',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: gridColumns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: maxWidth >= 600 ? 1.25 : 1.45,
            children: [
              WeatherDetailCard(
                icon: Icons.water_drop_rounded,
                label: 'Kelembapan',
                value: '${weather.current.relativeHumidity2m}%',
                iconColor: Colors.blue,
              ),
              WeatherDetailCard(
                icon: Icons.air_rounded,
                label: 'Kecepatan Angin',
                value: '${weather.current.windSpeed10m.toStringAsFixed(1)} km/j',
                iconColor: Colors.teal,
              ),
              WeatherDetailCard(
                icon: Icons.umbrella_rounded,
                label: 'Curah Hujan',
                value: '${weather.current.precipitation.toStringAsFixed(1)} mm',
                iconColor: Colors.indigo,
              ),
              WeatherDetailCard(
                icon: Icons.grain_rounded,
                label: 'Peluang Hujan',
                value: '${todayForecast?.precipitationProbabilityMax ?? 0}%',
                iconColor: Colors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Perkiraan Beberapa Hari ke Depan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weather.daily.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                return DailyForecastTile(
                  forecast: weather.daily[index],
                  isToday: index == 0,
                  formatTemp: (c) => vm.formatTemp(c, includeUnit: false),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesBar extends StatelessWidget {
  final WeatherViewModel vm;

  const _FavoritesBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: vm.favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = vm.favorites[index];
          final isSelected = city == vm.selectedLocation;
          return ChoiceChip(
            label: Text(city.name),
            selected: isSelected,
            avatar: Icon(
              Icons.star_rounded,
              size: 16,
              color: isSelected ? null : Colors.amber,
            ),
            onSelected: (_) => vm.selectLocation(city),
          );
        },
      ),
    );
  }
}

class _HeroWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final DailyForecast? todayForecast;
  final String Function(double celsius, {bool includeUnit}) formatTemp;

  const _HeroWeatherCard({
    required this.weather,
    required this.todayForecast,
    required this.formatTemp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final current = weather.current;
    final info = current.weatherInfo;
    final updatedTime = DateFormat('HH:mm').format(weather.fetchedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? const Color(0xFF262629) : const Color(0xFF2B2B30),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A40) : const Color(0xFF3F3F46),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.description,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terasa seperti ${formatTemp(current.apparentTemperature)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFD4D4D8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diperbarui $updatedTime',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA1A1AA),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                info.icon,
                size: 58,
                color: info.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTemp(current.temperature2m),
                style: theme.textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              if (todayForecast != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    'Min ${formatTemp(todayForecast!.temperature2mMin, includeUnit: false)} / Maks ${formatTemp(todayForecast!.temperature2mMax, includeUnit: false)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
