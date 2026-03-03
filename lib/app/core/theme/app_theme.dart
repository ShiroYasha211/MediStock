import 'package:flutter/material.dart';

class AppTheme {
  // --- MODERN PREMIUM COLOR PALETTE ---
  static const Color _primary = Color(0xFF1E3A8A); // Premium Deep Royal Blue
  static const Color _secondary = Color(0xFF0EA5E9); // Luminous Sky Blue

  static const Color _error = Color(0xFFEF4444); // Red
  static const Color _warning = Color(0xFFF59E0B); // Amber

  // --- MODERN NEUTRAL COLORS (LIGHT) ---
  static const Color _sidebarBg = Color(
    0xFFF8FAFC,
  ); // Very light grey blue for sidebar
  static const Color _background = Color(0xFFF1F5F9); // Light App Background
  static const Color _surface = Colors.white; // Pure white cards
  static const Color _onSurface = Color(0xFF0F172A); // Almost Black Text
  static const Color _onSurfaceVariant = Color(0xFF64748B); // Slate Grey Text

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
        surfaceVariant: const Color(
          0xFFE2E8F0,
        ), // For soft dividers and borders
        onSurfaceVariant: _onSurfaceVariant,
      ),

      textTheme: _textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: _surface, // Clean white app bar
        foregroundColor: _onSurface, // Text and icons will be dark
        elevation: 0, // Flat premium look
        scrolledUnderElevation: 2, // Slight shadow when scrolled
        shadowColor: Colors.black.withOpacity(0.05),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _onSurface,
          letterSpacing: -0.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0, // Flat in modern design
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ), // More rounded
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: _fontFamily,
                fontSize: 16,
              ),
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.hovered))
                  return Colors.white.withOpacity(0.1);
                if (states.contains(MaterialState.pressed))
                  return Colors.white.withOpacity(0.2);
                return null; // Defer to the widget's default.
              }),
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: _fontFamily,
            fontSize: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _secondary,
            width: 2,
          ), // Secondary glow
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: _onSurfaceVariant, fontSize: 15),
        floatingLabelStyle: const TextStyle(
          color: _secondary,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: TextStyle(color: _onSurfaceVariant.withOpacity(0.5)),
      ),

      cardTheme: CardThemeData(
        elevation: 6, // Softer, more diffuse shadow
        shadowColor: const Color(0xFF0F172A).withOpacity(0.08),
        color: _surface,
        surfaceTintColor:
            Colors.transparent, // Prevents material 3 color bleeding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Premium rounded cards
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),

      // --- NavigationRail Theme ---
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _sidebarBg,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorColor: _secondary.withOpacity(0.15),
        selectedIconTheme: const IconThemeData(color: _primary, size: 28),
        unselectedIconTheme: IconThemeData(
          color: _onSurfaceVariant.withOpacity(0.7),
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: _primary,
          fontWeight: FontWeight.bold,
          fontFamily: _fontFamily,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: _onSurfaceVariant,
          fontFamily: _fontFamily,
          fontSize: 12,
        ),
        labelType: NavigationRailLabelType.all,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _surface,
        elevation: 24,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B), // Slate 800
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: _fontFamily,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // --- MODERN PREMIUM COLOR PALETTE (DARK) ---
    const Color darkPrimary = Color(0xFF38BDF8); // Bright Sky Blue
    const Color darkSecondary = Color(0xFF818CF8); // Indigo
    const Color darkSidebarBg = Color(0xFF0F172A); // Slate 900
    const Color darkBackground = Color(0xFF020617); // Slate 950
    const Color darkSurface = Color(0xFF1E293B); // Slate 800
    const Color darkOnSurface = Color(0xFFF8FAFC); // Slate 50
    const Color darkOnSurfaceVariant = Color(0xFF94A3B8); // Slate 400

    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,

      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkBackground,
        secondary: darkSecondary,
        onSecondary: Colors.white,
        error: _error,
        onError: Colors.white,
        background: darkBackground,
        onBackground: darkOnSurface,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceVariant: const Color(0xFF334155), // Slate 700
        onSurfaceVariant: darkOnSurfaceVariant,
      ),

      textTheme: _textTheme.apply(
        bodyColor: darkOnSurface,
        displayColor: darkOnSurface,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface, // Dark AppBar
        foregroundColor: darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
          letterSpacing: -0.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: darkPrimary,
              foregroundColor: darkBackground, // Dark text on bright button
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontFamily: _fontFamily,
                fontSize: 16,
              ),
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.hovered))
                  return darkBackground.withOpacity(0.1);
                if (states.contains(MaterialState.pressed))
                  return darkBackground.withOpacity(0.2);
                return null;
              }),
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: _fontFamily,
            fontSize: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)), // Slate 700
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkOnSurfaceVariant, fontSize: 15),
        floatingLabelStyle: const TextStyle(
          color: darkPrimary,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: TextStyle(color: darkOnSurfaceVariant.withOpacity(0.5)),
      ),

      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkSidebarBg,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorColor: darkPrimary.withOpacity(0.15),
        selectedIconTheme: const IconThemeData(color: darkPrimary, size: 28),
        unselectedIconTheme: IconThemeData(
          color: darkOnSurfaceVariant.withOpacity(0.7),
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: darkPrimary,
          fontWeight: FontWeight.bold,
          fontFamily: _fontFamily,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: darkOnSurfaceVariant,
          fontFamily: _fontFamily,
          fontSize: 12,
        ),
        labelType: NavigationRailLabelType.all,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: darkSurface,
        elevation: 24,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: darkPrimary,
        contentTextStyle: const TextStyle(
          color: darkBackground,
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static TextTheme get _textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      color: _onSurface,
      letterSpacing: -1.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: _onSurface,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: _onSurface,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: _onSurface,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: _onSurface,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: _onSurface,
    ), // Slightly larger
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: _onSurface,
    ), // Slightly larger
    bodyLarge: TextStyle(
      fontSize: 16,
      color: _onSurface,
      height: 1.5,
    ), // Better line height
    bodyMedium: TextStyle(
      fontSize: 15,
      color: _onSurfaceVariant,
      height: 1.5,
    ), // Better line height
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  ).apply(fontFamily: _fontFamily);
}
