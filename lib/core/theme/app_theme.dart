import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.grey900,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(isLight: true),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.grey900),
        titleTextStyle: TextStyle(
          color: AppColors.grey900,
          fontSize: AppDimensions.textXXL,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.radiusLG)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize:
              const Size(double.infinity, AppDimensions.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimensions.textLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize:
              const Size(double.infinity, AppDimensions.buttonHeightMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimensions.textLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: AppDimensions.textMD,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.inputBorderWidth,
          ),
        ),
        labelStyle: const TextStyle(color: AppColors.grey500),
        hintStyle: const TextStyle(color: AppColors.grey400),
        errorStyle: const TextStyle(color: AppColors.error),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.grey700,
        size: AppDimensions.iconMD,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.grey700,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(isLight: false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: AppDimensions.textXXL,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.radiusLG)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isLight}) {
    final color = isLight ? AppColors.grey900 : AppColors.white;
    final baseStyle = GoogleFonts.poppins(color: color);

    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: AppDimensions.textHero,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: baseStyle.copyWith(
        fontSize: AppDimensions.textDisplay,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: baseStyle.copyWith(
        fontSize: AppDimensions.textXXXL,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: AppDimensions.textXXL,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseStyle.copyWith(
        fontSize: AppDimensions.textXL,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseStyle.copyWith(
        fontSize: AppDimensions.textLG,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseStyle.copyWith(
        fontSize: AppDimensions.textMD,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseStyle.copyWith(
        fontSize: AppDimensions.textSM,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseStyle.copyWith(
        fontSize: AppDimensions.textLG,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseStyle.copyWith(
        fontSize: AppDimensions.textMD,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseStyle.copyWith(
        fontSize: AppDimensions.textSM,
        fontWeight: FontWeight.w400,
        color: isLight ? AppColors.grey500 : AppColors.grey400,
      ),
      labelLarge: baseStyle.copyWith(
        fontSize: AppDimensions.textMD,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseStyle.copyWith(
        fontSize: AppDimensions.textXS,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
    );
  }
}
