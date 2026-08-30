import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyDense = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle orderNumberStamp = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle countdownDigits = TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  static TextTheme getLightTextTheme() {
    return const TextTheme(
      titleLarge: titleLarge,
      titleSmall: titleSmall,
      bodyLarge: body,
      bodyMedium: bodyDense,
      displayMedium: orderNumberStamp,
      displaySmall: countdownDigits,
    ).apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    );
  }

  static TextTheme getDarkTextTheme() {
    return const TextTheme(
      titleLarge: titleLarge,
      titleSmall: titleSmall,
      bodyLarge: body,
      bodyMedium: bodyDense,
      displayMedium: orderNumberStamp,
      displaySmall: countdownDigits,
    ).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );
  }
}
