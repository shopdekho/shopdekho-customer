import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors copied 1:1 from the website's CSS variables (index.html / s/index.html)
/// so the Flutter app keeps the exact same look.
class AppColors {
  // From index.html :root
  static const leaf = Color(0xFF1E9E4A);
  static const leafDark = Color(0xFF157A38);
  static const leafLight = Color(0xFF3DBE68);
  static const leafTint = Color(0xFFE6F7EC);

  static const blue = Color(0xFF2F6FED);
  static const blueTint = Color(0xFFE8F0FE);

  static const orange = Color(0xFFF5A623);
  static const orangeDark = Color(0xFFC97D0A);
  static const orangeTint = Color(0xFFFFF1DE);

  static const purple = Color(0xFF7C5CE0);
  static const purpleTint = Color(0xFFF0ECFE);

  static const red = Color(0xFFE5484D);
  static const redTint = Color(0xFFFDE8E8);

  static const ink = Color(0xFF1B2430);
  static const inkSoft = Color(0xFF6B7684);
  static const inkFaint = Color(0xFF9AA3AD);

  static const paper = Color(0xFFF7F8F6);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFEAECE9);

  // From s/index.html :root (shop detail page uses a slightly deeper green)
  static const green = Color(0xFF0E6B3A);
  static const greenDark = Color(0xFF093F22);
  static const greenMid = Color(0xFF159152);
  static const greenLight = Color(0xFFE6F4EB);
  static const gold = Color(0xFFE3A33B);
}

class AppRadius {
  static const lg = 20.0;
  static const md = 14.0;
  static const sm = 10.0;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.leaf,
        primary: AppColors.leaf,
      ),
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: GoogleFonts.inter().fontFamily,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
        ),
      ),
    );
  }

  /// "Baloo 2" headline look-alike used for brand text / titles on the site.
  static TextStyle brandFont({double size = 19, FontWeight weight = FontWeight.w800, Color? color}) {
    return GoogleFonts.baloo2(fontSize: size, fontWeight: weight, color: color ?? AppColors.ink);
  }
}
