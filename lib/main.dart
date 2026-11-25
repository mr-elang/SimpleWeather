import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = WeatherApiService();
  final storageService = LocalStorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(apiService, storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(apiService, storageService)..init(),
        ),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<WeatherViewModel, ThemeMode>(
      (vm) => vm.themeMode,
    );

    return MaterialApp(
      title: 'SimpleWeather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
