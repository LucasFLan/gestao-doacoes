import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _carregarPreferencia();
  }

  static const String _keyDarkMode = 'dark_mode_enabled';

  Future<void> _carregarPreferencia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_keyDarkMode);
      if (isDark != null) {
        state = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (_) {
      // Mantém system se falhar
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    state = enabled ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, enabled);
    } catch (_) {}
  }
}
