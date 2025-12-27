import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'doom_colors.dart';

class AppTheme {
  AppTheme._();

  static const _marvelRed = Color(0xFFE23636);
  static const _avengersGold = Color(0xFFFBB016);
  static const _deepCharcoal = Color(0xFF151515);
  static const _surfaceDark = Color(0xFF1E1E1E);
  static const _surfaceLight = Color(0xFFF5F5F5);
  static const _surfaceContainerLight = Color(0xFFFFFFFF);
  static const _doomGreen = Color(0xFF2D5A27);
  static const _vibraniumSilver = Color(0xFFBCC6CC);
  static const _infinityPurple = Color(0xFF6B3FA0);

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _deepCharcoal,
      textTheme: poppinsTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: _marvelRed,
        secondary: _avengersGold,
        tertiary: _doomGreen,
        surface: _deepCharcoal,
        surfaceContainer: _surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        error: _marvelRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _deepCharcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _marvelRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      extensions: const [
        DoomColors(
          doomGreen: _doomGreen,
          vibraniumSilver: _vibraniumSilver,
          infinityPurple: _infinityPurple,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _surfaceLight,
      textTheme: poppinsTextTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      colorScheme: const ColorScheme.light(
        primary: _marvelRed,
        secondary: _avengersGold,
        tertiary: _doomGreen,
        surface: _surfaceLight,
        surfaceContainer: _surfaceContainerLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black87,
        error: _marvelRed,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: poppinsTextTheme.titleLarge?.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardThemeData(
        color: _surfaceContainerLight,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _marvelRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      extensions: const [
        DoomColors(
          doomGreen: _doomGreen,
          vibraniumSilver: _vibraniumSilver,
          infinityPurple: _infinityPurple,
        ),
      ],
    );
  }
}
