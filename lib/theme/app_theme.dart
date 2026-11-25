import 'package:flutter/material.dart';

/// Centralized Material 3 theme configuration inspired by AccuWeather's
/// boxy card geometry and neutral charcoal-gray dark mode.
class AppTheme {
  static const Color _accentOrange = Color(0xFFF05514);
  static const double cardRadius = 8.0;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentOrange,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
    ).copyWith(
      primary: _accentOrange,
      onPrimary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF2F2F4),
      textTheme: _buildTextTheme(ThemeData.light().textTheme, colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFFF2F2F4),
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: Color(0xFFE0E0E4)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E5EA),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _accentOrange, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const bgGray = Color(0xFF141416);
    const cardGray = Color(0xFF222225);
    const borderGray = Color(0xFF333338);
    const secondaryText = Color(0xFFA1A1AA);

    final colorScheme = const ColorScheme.dark(
      primary: _accentOrange,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF33221B),
      onPrimaryContainer: Color(0xFFFFB599),
      secondary: Color(0xFF9CA3AF),
      onSecondary: Color(0xFF141416),
      surface: cardGray,
      onSurface: Color(0xFFF4F4F5),
      onSurfaceVariant: secondaryText,
      outline: borderGray,
      outlineVariant: borderGray,
      error: Color(0xFFEF4444),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgGray,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, colorScheme),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: bgGray,
        foregroundColor: Color(0xFFF4F4F5),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF4F4F5),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: borderGray),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardGray,
        selectedColor: const Color(0xFF343439),
        side: const BorderSide(color: borderGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderGray,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: _accentOrange, width: 1.5),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, ColorScheme colorScheme) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.4,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
