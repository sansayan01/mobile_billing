import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages app theme mode (light/dark) with Hive persistence.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_loadThemeMode());

  static ThemeMode _loadThemeMode() {
    try {
      final settingsBox = Hive.box('settings');
      final saved = settingsBox.get('theme_mode');
      if (saved == 'dark') return ThemeMode.dark;
      if (saved == 'system') return ThemeMode.system;
    } catch (_) {}
    return ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    try {
      Hive.box('settings').put('theme_mode', mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.system
              ? 'system'
              : 'light');
    } catch (_) {}
    emit(mode);
  }

  void toggleTheme() {
    setThemeMode(
      state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
