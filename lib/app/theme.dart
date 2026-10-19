import 'package:flutter/material.dart';

/// Warm, quiet palette: off-white paper, muted agricultural green, dark
/// neutral text. Large type and touch targets for easy daily use.
abstract final class AppColors {
  static const background = Color(0xFFFAF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const green = Color(0xFF3F6B3A);
  static const greenSoft = Color(0xFFE3EDDC);
  static const text = Color(0xFF1F2420);
  static const textMuted = Color(0xFF5B635A);
  static const border = Color(0xFFE2DDD0);
  static const amber = Color(0xFF8A5A00);
  static const amberSoft = Color(0xFFFFF1D6);
  static const red = Color(0xFFA3322A);
  static const redSoft = Color(0xFFFBE4E1);
  static const blueSoft = Color(0xFFE4ECF5);
  static const blue = Color(0xFF2D5585);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.green, brightness: Brightness.light).copyWith(
    primary: AppColors.green,
    onPrimary: Colors.white,
    primaryContainer: AppColors.greenSoft,
    onPrimaryContainer: AppColors.text,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    error: AppColors.red,
  );

  const radius = BorderRadius.all(Radius.circular(14));
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = base.textTheme
      .copyWith(
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
        titleMedium: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.35),
        titleSmall: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.35),
        bodyLarge: const TextStyle(fontSize: 18, height: 1.45),
        bodyMedium: const TextStyle(fontSize: 16, height: 1.45),
        bodySmall: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textMuted),
        labelLarge: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25),
      )
      // Colours last: the size overrides above carry no colour of their own.
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);
  final textTheme = text.copyWith(bodySmall: text.bodySmall!.copyWith(color: AppColors.textMuted));

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: AppColors.text),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        shape: const RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.green, width: 2),
      ),
      labelStyle: TextStyle(fontSize: 17),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.greenSoft,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 14,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: AppColors.text,
        ),
      ),
    ),
    chipTheme: const ChipThemeData(
      labelStyle: TextStyle(fontSize: 16, color: AppColors.text),
      side: BorderSide(color: AppColors.border),
      shape: StadiumBorder(),
    ),
    segmentedButtonTheme: const SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(48, 48)),
        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        side: WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      minVerticalPadding: 10,
      titleTextStyle: TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.w500),
      subtitleTextStyle: TextStyle(fontSize: 15, color: AppColors.textMuted),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      contentTextStyle: TextStyle(fontSize: 16),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}
