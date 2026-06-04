import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController {
  AppLocaleController._();

  static final AppLocaleController instance = AppLocaleController._();
  static const _storageKey = 'app_locale_code';

  final ValueNotifier<Locale> localeListenable = ValueNotifier(
    const Locale('en'),
  );

  Locale get locale => localeListenable.value;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    final code = preferences.getString(_storageKey);
    if (code != null && _supportedCodes.contains(code)) {
      localeListenable.value = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = Locale(locale.languageCode);
    if (!_supportedCodes.contains(normalized.languageCode)) return;

    localeListenable.value = normalized;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, normalized.languageCode);
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  static const _supportedCodes = {
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ja',
    'ko',
    'zh',
  };
}
