// lib/services/theme_service.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Service to persist and retrieve theme preferences
class ThemeService {
  static const String _themeBoxName = '_themebox';
  static const String _themeModeKey = 'themeMode';

  /// Get the saved theme mode
  Future<ThemeMode> getThemeMode() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final themeModeString =
          box.get(_themeModeKey, defaultValue: 'light') as String;

      switch (themeModeString) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
        default:
          return ThemeMode.light;
      }
    } catch (e) {
      print('Error loading theme: $e');
      return ThemeMode.light; // Default to light theme
    }
  }

  /// Save the theme mode
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      final themeModeString = mode == ThemeMode.dark ? 'dark' : 'light';
      await box.put(_themeModeKey, themeModeString);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  /// Clear theme preference (reset to default)
  Future<void> clearThemePreference() async {
    try {
      final box = await Hive.openBox(_themeBoxName);
      await box.delete(_themeModeKey);
    } catch (e) {
      print('Error clearing theme preference: $e');
    }
  }
}
