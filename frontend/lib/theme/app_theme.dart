import 'package:flutter/material.dart';

/// Central place for the app's light and dark themes.
/// Screens should read colors from Theme.of(context) instead of hardcoding them,
/// so they switch automatically when the mode changes.
class AppTheme {
  AppTheme._();

  static const Color _darkBg = Color(0xFF101A1A);
  static const Color _darkSurface = Color(0xFF192626);
  static const Color _lightBg = Color(0xFFF4F7F4);

  static final ThemeData dark = _build(
    const ColorScheme.dark(
      primary: Color(0xFFB6EF86),
      onPrimary: Colors.black,
      secondary: Color(0xFF00B0FF),
      onSecondary: Colors.black,
      surface: _darkSurface,
      onSurface: Colors.white,
      error: Color(0xFFFF5252),
    ),
    scaffold: _darkBg,
    fieldFill: const Color(0xFF101A1A),
  );

  static final ThemeData light = _build(
    const ColorScheme.light(
      primary: Color(0xFF326B36),
      onPrimary: Colors.white,
      secondary: Color(0xFF0288D1),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF18291E),
      error: Color(0xFFD32F2F),
    ),
    scaffold: _lightBg,
    fieldFill: const Color(0xFFEAF0EE),
  );

  static ThemeData _build(
    ColorScheme scheme, {
    required Color scaffold,
    required Color fieldFill,
  }) {
    final isDark = scheme.brightness == Brightness.dark;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return ThemeData(
      fontFamily: 'Roboto',
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: isDark ? 0 : 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(scheme.primary, 1.5),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.5),
        prefixIconColor: scheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.25)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.onSurface.withValues(alpha: 0.1),
        space: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
    );
  }
}
