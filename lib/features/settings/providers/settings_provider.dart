import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/app_providers.dart';

const String _themeModeKey = 'theme_mode';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

class SettingsNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _prefs.getString(_themeModeKey);
    if (saved != null) state = _fromString(saved);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeModeKey, _toString(mode));
  }

  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  String _toString(ThemeMode m) =>
      m == ThemeMode.light ? 'light' : m == ThemeMode.dark ? 'dark' : 'system';

  ThemeMode _fromString(String v) => v == 'light'
      ? ThemeMode.light
      : v == 'dark'
          ? ThemeMode.dark
          : ThemeMode.system;
}

