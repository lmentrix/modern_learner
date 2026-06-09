import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  dark,
  light,
  system;

  ThemeMode get themeMode {
    return switch (this) {
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.system => ThemeMode.system,
    };
  }

  String get label {
    return switch (this) {
      AppThemePreference.dark => 'Dark',
      AppThemePreference.light => 'Light',
      AppThemePreference.system => 'System',
    };
  }
}

class AppThemeController {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();
  static const _storageKey = 'app_theme_preference';

  final ValueNotifier<AppThemePreference> preferenceListenable =
      ValueNotifier<AppThemePreference>(AppThemePreference.dark);

  AppThemePreference get preference => preferenceListenable.value;
  ThemeMode get themeMode => preference.themeMode;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_storageKey);
    final preference = AppThemePreference.values
        .where((item) => item.name == stored)
        .firstOrNull;
    if (preference != null) {
      preferenceListenable.value = preference;
    }
  }

  Future<void> setPreference(AppThemePreference preference) async {
    preferenceListenable.value = preference;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, preference.name);
  }
}
