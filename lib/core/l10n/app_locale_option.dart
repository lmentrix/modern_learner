import 'package:flutter/material.dart';

class AppLocaleOption {
  const AppLocaleOption({
    required this.flag,
    required this.label,
    required this.nativeName,
    required this.locale,
  });

  final String flag;
  final String label;
  final String nativeName;
  final Locale locale;
}

const appLocaleOptions = [
  AppLocaleOption(
    flag: '🇺🇸',
    label: 'English (US)',
    nativeName: 'English',
    locale: Locale('en'),
  ),
  AppLocaleOption(
    flag: '🇪🇸',
    label: 'Spanish',
    nativeName: 'Español',
    locale: Locale('es'),
  ),
  AppLocaleOption(
    flag: '🇫🇷',
    label: 'French',
    nativeName: 'Français',
    locale: Locale('fr'),
  ),
  AppLocaleOption(
    flag: '🇩🇪',
    label: 'German',
    nativeName: 'Deutsch',
    locale: Locale('de'),
  ),
  AppLocaleOption(
    flag: '🇮🇹',
    label: 'Italian',
    nativeName: 'Italiano',
    locale: Locale('it'),
  ),
  AppLocaleOption(
    flag: '🇵🇹',
    label: 'Portuguese',
    nativeName: 'Português',
    locale: Locale('pt'),
  ),
  AppLocaleOption(
    flag: '🇯🇵',
    label: 'Japanese',
    nativeName: '日本語',
    locale: Locale('ja'),
  ),
  AppLocaleOption(
    flag: '🇰🇷',
    label: 'Korean',
    nativeName: '한국어',
    locale: Locale('ko'),
  ),
  AppLocaleOption(
    flag: '🇨🇳',
    label: 'Mandarin',
    nativeName: '中文',
    locale: Locale('zh'),
  ),
];

AppLocaleOption appLocaleOptionForLabel(String label) {
  return appLocaleOptions.firstWhere(
    (option) => option.label == label,
    orElse: () => appLocaleOptions.first,
  );
}

AppLocaleOption appLocaleOptionForLocale(Locale locale) {
  return appLocaleOptions.firstWhere(
    (option) => option.locale.languageCode == locale.languageCode,
    orElse: () => appLocaleOptions.first,
  );
}
