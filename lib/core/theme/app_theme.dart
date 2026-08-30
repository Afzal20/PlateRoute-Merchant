import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text style tokens matching the design spec.
abstract final class AppTextStyles {
  // Font families
  static const _inter = 'Inter';
  static const _mono = 'RobotoMono';

  // Title L — 22/28 SemiBold — screen headers
  static const titleL = TextStyle(
    fontFamily: _inter,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  // Title S — 18/24 SemiBold — card titles
  static const titleS = TextStyle(
    fontFamily: _inter,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  // Order number stamp — 20/26 Bold monospaced
  static const orderNumber = TextStyle(
    fontFamily: _mono,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Body — 16/24
  static const body = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  // Body medium — 16/24 Medium
  static const bodyMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );

  // Dense — 14/20 — history lists only
  static const dense = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  // Countdown digits — 22 SemiBold tabular
  static const countdown = TextStyle(
    fontFamily: _mono,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Stat numbers — Bold 20 tabular
  static const statNumber = TextStyle(
    fontFamily: _inter,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Stat label — 11 uppercase overline
  static const statLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
  );

  // Caption
  static const caption = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );

  // Button — Bold 16
  static const button = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  // Price — tabular SemiBold
  static const price = TextStyle(
    fontFamily: _mono,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);
}

/// Touch floor constants
abstract final class AppSizes {
  static const touchPrimary = 56.0;
  static const touchSecondary = 48.0;
  static const listRow = 64.0;
  static const thumbnailSize = 56.0;
  static const countdownRingSize = 56.0;
  static const countdownRingStroke = 5.0;
  static const availabilityTrackWidth = 84.0;
  static const availabilityThumbSize = 40.0;
  static const urgencyBorderWidth = 3.0;
  static const borderRadius = 12.0;
  static const cardRadius = 12.0;
  static const spacingXS = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 16.0;
  static const spacingL = 24.0;
  static const spacingXL = 32.0;
}

/// Light theme
ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.actionAccept,
      error: AppColors.lateAlarm,
      surface: AppColors.surfaceLight,
    ),
    scaffoldBackgroundColor: AppColors.canvasLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.titleL,
    ),
    textTheme: _buildTextTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryLight,
    ),
    dividerColor: const Color(0xFFE2E8F0),
    cardColor: AppColors.surfaceLight,
  );
}

/// Dark theme — ships as default per spec
ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.actionAcceptDark,
      error: AppColors.lateAlarm,
      surface: AppColors.surfaceDark,
    ),
    scaffoldBackgroundColor: AppColors.canvasDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
    ),
    textTheme: _buildTextTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textSecondaryDark,
    ),
    dividerColor: AppColors.divider,
    cardColor: AppColors.surfaceDark,
  );
}

TextTheme _buildTextTheme(Color primary, Color secondary) {
  return TextTheme(
    displayLarge: AppTextStyles.titleL.copyWith(color: primary),
    titleLarge: AppTextStyles.titleL.copyWith(color: primary),
    titleMedium: AppTextStyles.titleS.copyWith(color: primary),
    bodyLarge: AppTextStyles.body.copyWith(color: primary),
    bodyMedium: AppTextStyles.body.copyWith(color: secondary),
    bodySmall: AppTextStyles.dense.copyWith(color: secondary),
    labelLarge: AppTextStyles.button.copyWith(color: primary),
    labelSmall: AppTextStyles.caption.copyWith(color: secondary),
  );
}
