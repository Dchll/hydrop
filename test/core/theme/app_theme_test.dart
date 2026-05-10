import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrop/core/theme/app_theme.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:hydrop/gen/colors.gen.dart';

void main() {
  group('AppTheme', () {
    test('builds the light color scheme from generated colors', () {
      final theme = AppTheme.light();

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, ColorName.lightAccent);
      expect(theme.colorScheme.surface, ColorName.lightBackground);
      expect(theme.colorScheme.onSurface, ColorName.lightForeground);
      expect(theme.scaffoldBackgroundColor, ColorName.lightBackground);
    });

    test('builds the dark color scheme from generated colors', () {
      final theme = AppTheme.dark();

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, ColorName.darkAccent);
      expect(theme.colorScheme.surface, ColorName.darkBackground);
      expect(theme.colorScheme.onSurface, ColorName.darkForeground);
      expect(theme.scaffoldBackgroundColor, ColorName.darkBackground);
    });
  });

  group('AppThemeModeX', () {
    test('maps persisted modes to Material ThemeMode values', () {
      expect(AppThemeMode.system.materialThemeMode, ThemeMode.system);
      expect(AppThemeMode.light.materialThemeMode, ThemeMode.light);
      expect(AppThemeMode.dark.materialThemeMode, ThemeMode.dark);
    });
  });
}
