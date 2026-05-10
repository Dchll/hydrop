import 'package:flutter/material.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:hydrop/gen/colors.gen.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: ColorName.lightAccent,
          brightness: Brightness.light,
        ).copyWith(
          primary: ColorName.lightAccent,
          secondary: ColorName.lightAccent,
          surface: ColorName.lightBackground,
          onSurface: ColorName.lightForeground,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorName.lightBackground,
    );
  }

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: ColorName.darkAccent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: ColorName.darkAccent,
          secondary: ColorName.darkAccent,
          surface: ColorName.darkBackground,
          onSurface: ColorName.darkForeground,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ColorName.darkBackground,
    );
  }
}

extension AppThemeModeX on AppThemeMode {
  ThemeMode get materialThemeMode {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}
