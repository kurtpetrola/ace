// lib/core/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/services/theme_service.dart';

/// Provider for theme mode state
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService _themeService = ThemeService();

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    final savedTheme = await _themeService.getThemeMode();
    state = savedTheme;
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newTheme =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newTheme;
    await _themeService.saveThemeMode(newTheme);
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _themeService.saveThemeMode(mode);
  }

  /// Check if dark mode is enabled
  bool get isDarkMode => state == ThemeMode.dark;
}
