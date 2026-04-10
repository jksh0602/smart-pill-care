// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand
  static const primary = Color(0xFF5A6BFF);
  static const primaryLight = Color(0xFFE8ECFF);
  static const primaryDark = Color(0xFF3B4FCC);

  // Background
  static const bgPage = Color(0xFFF0F3FF);       // 홈 배경 그라디언트 시작
  static const bgCard = Colors.white;
  static const bgSecondary = Color(0xFFF6F7FB);

  // Status
  static const success = Color(0xFF3ECF6E);
  static const successLight = Color(0xFFECFDF5);
  static const warning = Color(0xFFF5A623);
  static const warningLight = Color(0xFFFFFDE7);
  static const danger = Color(0xFFE24B4A);
  static const dangerLight = Color(0xFFFFF5F5);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  // Elder mode (dark bg)
  static const elderBg = Color(0xFF0F1229);
  static const elderCard = Color(0xFF1A2040);

  // Guardian mode
  static const guardianAccent = Color(0xFF7F77DD);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'NotoSansKR',
    scaffoldBackgroundColor: AppColors.bgPage,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}
