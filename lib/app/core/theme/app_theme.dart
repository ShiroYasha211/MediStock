import 'package:flutter/material.dart';

class AppTheme {
  // --- NEW COLOR PALETTE ---
  static const Color _primary = Color(0xFF2C3E50); // Deep Blue
  static const Color _secondary = Color(0xFF1ABC9C); // Teal
  static const Color _error = Color(0xFFE74C3C); // Red
  static const Color _warning = Color(0xFFF1C40F); // Yellow

  // --- NEW NEUTRAL COLORS ---
  static const Color _sidebarBg = Color(0xFF34495E); // Sidebar Background
  static const Color _background = Color(0xFFECF0F1); // Content Background
  static const Color _surface = Colors.white; // Cards Background
  static const Color _onSurface = Color(0xFF2C3E50); // Main Text Color
  static const Color _onSurfaceVariant = Color(0xFF7F8C8D); // Secondary Text

  static const String _fontFamily = 'Cairo';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _background,

      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: Colors.white,
        secondary: _secondary,
        onSecondary: Colors.white,
        error: _error,
        onError: Colors.white,
        background: _background,
        onBackground: _onSurface,
        surface: _surface,
        onSurface: _onSurface,
        surfaceVariant: const Color(0xFFBDC3C7), // For dividers and borders
        onSurfaceVariant: _onSurfaceVariant,
      ),

      textTheme: _textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: _surface, // AppBar will be white
        foregroundColor: _onSurface, // Text and icons will be dark
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _onSurface,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: _fontFamily),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _onSurfaceVariant),
        floatingLabelStyle: const TextStyle(color: _primary),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        color: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // --- NEW: NavigationRail Theme ---
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _sidebarBg,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        indicatorColor: _primary.withOpacity(0.8),
        selectedIconTheme: const IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: _onSurfaceVariant.withOpacity(0.8)),
        selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        unselectedLabelTextStyle: TextStyle(
          color: _onSurfaceVariant,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  // Same TextTheme as before, but it will inherit the new colors
  static TextTheme get _textTheme => const TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w800, color: _onSurface),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _onSurface),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _onSurface),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: _onSurface),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _onSurface),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _onSurface),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onSurface),
    bodyLarge: TextStyle(fontSize: 16, color: _onSurface),
    bodyMedium: TextStyle(fontSize: 14, color: _onSurfaceVariant),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  ).apply(fontFamily: _fontFamily);
}
