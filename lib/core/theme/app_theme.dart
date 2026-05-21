import 'package:flutter/material.dart';
import 'package:hydrop/data/local/model/setting/setting.dart';
import 'package:hydrop/gen/colors.gen.dart';

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'MiSans';

  static ThemeData light() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: ColorName.lightForeground,
      onPrimary: ColorName.lightBackground,
      secondary: ColorName.lightForeground,
      onSecondary: ColorName.lightBackground,
      error: Color(0xFF444444),
      onError: ColorName.lightBackground,
      surface: ColorName.lightBackground,
      onSurface: ColorName.lightForeground,
      outline: Color(0xFFD0D0D0),
      outlineVariant: Color(0xFFE2E2E2),
      shadow: ColorName.black50,
      scrim: ColorName.black50,
      inverseSurface: Color(0xFF111111),
      onInverseSurface: ColorName.lightBackground,
      inversePrimary: ColorName.lightBackground,
      tertiary: Color(0xFF666666),
      onTertiary: ColorName.lightBackground,
      surfaceTint: ColorName.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: ColorName.lightBackground,
      canvasColor: ColorName.lightBackground,
      dividerColor: colorScheme.outline,
      splashFactory: InkRipple.splashFactory,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: colorScheme.onSurface,
          foregroundColor: colorScheme.surface,
          side: BorderSide(color: colorScheme.onSurface, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        modalBarrierColor: ColorName.black50,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.onSurface.withValues(alpha: 0.08),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.6),
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.onSurface),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withValues(alpha: 0.58),
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.64),
        ),
        indicatorColor: colorScheme.onSurface.withValues(alpha: 0.08),
        useIndicator: true,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: ColorName.darkForeground,
      onPrimary: ColorName.darkBackground,
      secondary: ColorName.darkForeground,
      onSecondary: ColorName.darkBackground,
      error: Color(0xFFBFBFBF),
      onError: ColorName.darkBackground,
      surface: Color(0xFF141414),
      onSurface: ColorName.darkForeground,
      outline: Color(0xFF3A3A3A),
      outlineVariant: Color(0xFF2A2A2A),
      shadow: ColorName.black50,
      scrim: ColorName.black50,
      inverseSurface: ColorName.darkForeground,
      onInverseSurface: ColorName.darkBackground,
      inversePrimary: ColorName.darkBackground,
      tertiary: Color(0xFF8A8A8A),
      onTertiary: ColorName.darkBackground,
      surfaceTint: ColorName.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: ColorName.darkBackground,
      canvasColor: ColorName.darkBackground,
      dividerColor: colorScheme.outline,
      splashFactory: InkRipple.splashFactory,
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: colorScheme.onSurface,
          foregroundColor: colorScheme.surface,
          side: BorderSide(color: colorScheme.onSurface, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        modalBarrierColor: ColorName.black50,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.onSurface.withValues(alpha: 0.1),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.6),
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.onSurface),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withValues(alpha: 0.58),
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.64),
        ),
        indicatorColor: colorScheme.onSurface.withValues(alpha: 0.1),
        useIndicator: true,
      ),
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
