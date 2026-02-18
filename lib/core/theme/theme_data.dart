// lib/core/theme/theme_data.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';

/// App theme configuration
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: ColorPalette.primary,
      scaffoldBackgroundColor: Colors.white,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.accentBlack,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorPalette.accentBlack),
        titleTextStyle: TextStyle(
          color: ColorPalette.accentBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorPalette.secondary,
        selectedItemColor: ColorPalette.primary,
        unselectedItemColor: ColorPalette.darkGrey,
        selectedIconTheme: IconThemeData(size: 30),
        unselectedIconTheme: IconThemeData(size: 26),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ColorPalette.accentBlack),
        bodyMedium: TextStyle(color: ColorPalette.accentBlack),
        bodySmall: TextStyle(color: ColorPalette.darkGrey),
        titleLarge: TextStyle(
          color: ColorPalette.accentBlack,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: ColorPalette.accentBlack,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(color: ColorPalette.darkGrey),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: ColorPalette.accentBlack,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: ColorPalette.lightGray,
        thickness: 1,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: ColorPalette.darkGrey),
        hintStyle: const TextStyle(color: ColorPalette.hintColor),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorPalette.primary,
      ),

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: ColorPalette.primary,
        secondary: ColorPalette.secondary,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: ColorPalette.accentBlack,
        onSurface: ColorPalette.accentBlack,
        onError: Colors.white,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: ColorPalette.primary,
      scaffoldBackgroundColor: ColorPalette.accentBlack,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorPalette.accentBlack,
        foregroundColor: ColorPalette.secondary,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorPalette.secondary),
        titleTextStyle: TextStyle(
          color: ColorPalette.secondary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorPalette.secondary,
        selectedItemColor: Colors.black,
        unselectedItemColor:
            Colors.black54, // Simplified opacity for cleaner code
        selectedIconTheme: IconThemeData(size: 30),
        unselectedIconTheme: IconThemeData(size: 26),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: ColorPalette.darkGrey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ColorPalette.secondary),
        bodyMedium: TextStyle(color: ColorPalette.secondary),
        bodySmall: TextStyle(color: ColorPalette.lightGray),
        titleLarge: TextStyle(
          color: ColorPalette.secondary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: ColorPalette.secondary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(color: ColorPalette.lightGray),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: ColorPalette.secondary,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: ColorPalette.darkGrey,
        thickness: 1,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.darkGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: ColorPalette.lightGray),
        hintStyle: const TextStyle(color: ColorPalette.hintColor),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorPalette.primary,
      ),

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: ColorPalette.primary,
        secondary: ColorPalette.secondary,
        surface: ColorPalette.darkGrey,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: ColorPalette.accentBlack,
        onSurface: ColorPalette.secondary,
        onError: Colors.white,
      ),
    );
  }
}
