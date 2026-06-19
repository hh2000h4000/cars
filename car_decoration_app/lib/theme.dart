import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const dark = Color(0xFF15140F);
  static const darkMedium = Color(0xFF2A2618);
  static const darkCard = Color(0xFF23211A);
  static const darkBorder = Color(0xFF2F2B20);
  static const goldLight = Color(0xFFE4CC7E);
  static const gold = Color(0xFFB5923F);
  static const goldText = Color(0xFFA07E2E);
  static const goldMuted = Color(0xFFC9B98E);
  static const goldBg = Color(0xFFF6EFDD);
  static const surface = Color(0xFFFAF8F4);
  static const background = Color(0xFFE7E5DF);
  static const cardBg = Color(0xFFFFFFFF);
  static const border = Color(0xFFECE8DF);
  static const borderStrong = Color(0xFFD9BC6E);
  static const textPrimary = Color(0xFF15140F);
  static const textSecondary = Color(0xFF7A766C);
  static const textMuted = Color(0xFFA8A399);
  static const green = Color(0xFF2E7D5B);
  static const greenLight = Color(0xFFEAF5EF);
  static const greenBorder = Color(0xFFCDE7DA);
  static const red = Color(0xFFC0432F);
  static const redLight = Color(0xFFFBEDEA);
  static const redBorder = Color(0xFFF2D4CE);
  static const star = Color(0xFFE4B53C);
  static const adminText = Color(0xFFFBF7EC);
  static const adminTextMuted = Color(0xFF9C9277);
}

class AppTheme {
  static TextTheme _buildTextTheme() => TextTheme(
        displayLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        headlineLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w900),
        headlineMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        headlineSmall: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
        titleSmall: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        bodyMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        bodySmall: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        labelLarge: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        labelMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
        labelSmall: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.goldText,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: _buildTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.tajawal(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.goldText, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      );
}
