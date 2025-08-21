import 'package:flutter/material.dart';
import 'package:move_young/theme/tokens.dart';

// where AppFonts lives

class AppFonts {
  static const family = 'Poppins'; // keep here if not already in tokens.dart
}

class AppTheme {
  /// Minimal theme: sets Poppins globally, touches nothing else.
  static ThemeData minimal() {
    return ThemeData(
      useMaterial3: true, // optional; remove if you prefer M2
      fontFamily: AppFonts.family,
      scaffoldBackgroundColor: AppColors.white,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.blackIcon, // title + icons
        surfaceTintColor: Colors.transparent, // kill M3 grey tint
        elevation: 0,
        centerTitle: true,
        // If you want a consistent title style everywhere:

        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w500, // nice semi-bold
          color: AppColors.blackText, // 87% black
          letterSpacing: 0.15,
        ),

        iconTheme: IconThemeData(color: AppColors.blackIcon),
      ), // no colors, no shapes, no component themes
    );
  }
}
