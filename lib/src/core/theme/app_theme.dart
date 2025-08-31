import 'package:flutter/material.dart';

class AppColors {
  static const c021024 = Color(0xFF021024);
  static const c052659 = Color(0xFF052659);
  static const c5483b3 = Color(0xFF5483B3);
  static const c7da0ca = Color(0xFF7DA0CA);
  static const cc1e8ff = Color(0xFFC1E8FF);
  static const cd9e1f1 = Color(0xFFD9E1F1);

  static const gradientMain = LinearGradient(
    colors: [c021024, c052659, c5483b3, c7da0ca],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSoft = LinearGradient(
    colors: [cc1e8ff, cd9e1f1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.c5483b3,
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}