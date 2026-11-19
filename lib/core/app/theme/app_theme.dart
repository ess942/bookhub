import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.actionBlue,
      primary: AppColors.actionBlue,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get dark {
    const background = Color(0xFF0B1220);
    const surface = Color(0xFF111C2F);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.actionBlue,
      brightness: Brightness.dark,
      primary: const Color(0xFF7AA7FF),
      surface: surface,
      error: const Color(0xFFFF6B6B),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
