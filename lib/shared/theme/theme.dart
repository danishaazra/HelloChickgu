import 'package:flutter/material.dart';

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

    return base.copyWith(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: bgLightBlue,

      // appbar theme
      appBarTheme: AppBarTheme(
        backgroundColor: bgWhite,
        titleTextStyle: const TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(size: 36, color: Colors.black),
        actionsIconTheme: const IconThemeData(size: 36, color: Colors.black),
      ),

      // text theme
      textTheme: base.textTheme.apply(
        fontFamily: 'Baloo2',
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      ),

      // color scheme
      colorScheme: base.colorScheme.copyWith(
        primary: primaryBlue,
        secondary: primaryYellow,
        background: bgLightBlue,
        surface: bgWhite,
      ),
    );
  }
}
