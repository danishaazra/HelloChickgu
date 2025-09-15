import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color primaryYellow = Color(0xFFF4B942);
  static const Color secondaryPink = Color(0xFFFFA3B3);
  static const Color secondaryMint = Color(0xFF95EECB);
  static const Color bgLightBlue = Color(0xFFECF4F9);
  static const Color bgWhite = Color(0xFFFFFFFF);

  // ThemeData
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final baloo2TextTheme = GoogleFonts.baloo2TextTheme(base.textTheme);

    return base.copyWith(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgLightBlue,
      textTheme: baloo2TextTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: primaryBlue,
        secondary: primaryYellow,
        background: bgLightBlue,
        surface: bgWhite,
      ),
    );
  }
}
