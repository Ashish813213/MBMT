import 'package:flutter/material.dart';

/// MBMT visual language.
///
/// Blue + green are the primary colours. Orange and red appear *only* for
/// alerts and important status. Rounded cards, soft shadows, generous spacing,
/// large touch targets, high-legibility type.
class AppColors {
  AppColors._();

  static const Color brand = Color(0xFF1A4FBD); // primary blue
  static const Color brandDark = Color(0xFF14408F);
  static const Color brandSoft = Color(0xFFEAF1FF);

  static const Color live = Color(0xFF0B8F55); // green - bus / live status
  static const Color live700 = Color(0xFF0A7546); // darker green for text on tint
  static const Color liveSoft = Color(0xFFE4F6EC);

  static const Color warn = Color(0xFFF97316); // orange - warnings
  static const Color warnSoft = Color(0xFFFFF1E6);

  static const Color danger = Color(0xFFDC2626); // red - critical alerts
  static const Color dangerSoft = Color(0xFFFDECEC);

  static const Color purple = Color(0xFF7C3AED); // passes accent

  static const Color ink = Color(0xFF0F172A);
  static const Color inkSoft = Color(0xFF475569);
  static const Color muted = Color(0xFF94A3B8);

  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF6F8FB);
  static const Color pageBg = Color(0xFFEEF1F6);
  static const Color line = Color(0xFFE7EBF1);
}

class AppTheme {
  AppTheme._();

  static ThemeData light({bool highContrast = false}) {
    final Color textPrimary = highContrast ? Colors.black : AppColors.ink;
    final Color textSecondary = highContrast ? const Color(0xFF1F2937) : AppColors.inkSoft;
    final Color outline = highContrast ? const Color(0xFF334155) : AppColors.line;
    final Color pageBg = highContrast ? Colors.white : AppColors.pageBg;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      secondary: AppColors.live,
      error: AppColors.danger,
      surface: AppColors.surface,
    ).copyWith(
      onSurface: textPrimary,
      outline: outline,
    );

    final TextTheme base = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: pageBg,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: base
          .apply(bodyColor: textPrimary, displayColor: textPrimary)
          .copyWith(
            titleLarge: base.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
            titleMedium: base.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            bodyMedium: base.bodyMedium?.copyWith(color: textSecondary, height: 1.35),
            bodySmall: base.bodySmall?.copyWith(color: textSecondary, height: 1.3),
            labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: outline),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: highContrast ? Colors.white : AppColors.surfaceAlt,
        hintStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.brandSoft,
        side: BorderSide(color: outline),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.brand,
        minVerticalPadding: 12,
      ),
    );
  }
}

/// Spacing scale (8px system).
class Gap {
  Gap._();
  static const SizedBox x4 = SizedBox(width: 4, height: 4);
  static const SizedBox x8 = SizedBox(width: 8, height: 8);
  static const SizedBox x12 = SizedBox(width: 12, height: 12);
  static const SizedBox x16 = SizedBox(width: 16, height: 16);
  static const SizedBox x24 = SizedBox(width: 24, height: 24);
  static const SizedBox x32 = SizedBox(width: 32, height: 32);
}
