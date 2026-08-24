import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AppNavigationMode { bottomNav, drawer }

class NavigationCubit extends Cubit<AppNavigationMode> {
  NavigationCubit() : super(_loadMode());

  static AppNavigationMode _loadMode() {
    try {
      final settingsBox = Hive.box('settings');
      final saved = settingsBox.get('nav_mode');
      if (saved == 'drawer') return AppNavigationMode.drawer;
    } catch (_) {}
    return AppNavigationMode.bottomNav;
  }

  void setMode(AppNavigationMode mode) {
    try {
      Hive.box('settings').put(
        'nav_mode',
        mode == AppNavigationMode.drawer ? 'drawer' : 'bottom',
      );
    } catch (_) {}
    emit(mode);
  }

  void toggle() {
    setMode(
      state == AppNavigationMode.bottomNav
          ? AppNavigationMode.drawer
          : AppNavigationMode.bottomNav,
    );
  }
}
