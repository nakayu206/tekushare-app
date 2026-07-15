import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyle {
  // サイズ定数
  static const double xxs = 9.0;
  static const double xs = 11.0;
  static const double xs2 = 12.0;
  static const double sm = 13.0;
  static const double sm2 = 14.0;
  static const double md = 15.0;
  static const double md2 = 16.0;
  static const double lg = 17.0;
  static const double lg2 = 18.0;
  static const double xl = 20.0;
  static const double x1l = 22.0;
  static const double x2l = 24.0;
  static const double x3l = 32.0;
  static const double timer = 56.0;
  static const double clock = 96.0;

  // ウェイト定数
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;

  // よく使うTextStyleセット
  static const timerDisplay = TextStyle(
    fontSize: timer,
    fontWeight: bold,
    color: AppColors.textPrimary,
  );
  static const titleLarge = TextStyle(
    fontSize: xl,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
  );
  static const titleMedium = TextStyle(
    fontSize: lg,
    fontWeight: medium,
    color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontSize: md,
    fontWeight: regular,
    color: AppColors.textPrimary,
  );
  static const labelMedium = TextStyle(
    fontSize: sm,
    fontWeight: medium,
    color: AppColors.textPrimary,
  );
  static const captionSecondary = TextStyle(
    fontSize: xs,
    fontWeight: regular,
    color: AppColors.textDisabled,
  );
}
