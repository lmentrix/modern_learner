import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:modern_learner_production/core/l10n/app_locale_controller.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_theme.dart';
import 'package:modern_learner_production/core/theme/app_theme_controller.dart';
import 'package:modern_learner_production/l10n/generated/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.instance.localeListenable,
      builder: (context, locale, _) {
        return ValueListenableBuilder<AppThemePreference>(
          valueListenable: AppThemeController.instance.preferenceListenable,
          builder: (context, preference, _) {
            return MaterialApp.router(
              title: 'Modern Learner',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: preference.themeMode,
              locale: locale,
              supportedLocales: AppLocaleController.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: AppRouter.router,
            );
          },
        );
      },
    );
  }
}
