import 'package:flutter/material.dart';

class AppColors {
  static const darkGreen = Color(0xFF071e07);
  static const green1 = Color(0xff0e320f);
  static const green2 = Color(0xff0f4203);
  static const green3 = Color(0xFF2d531a);
  static const green4 = Color(0xFF305700);
  static const green5 = Color(0xFF5b7917);
  static const green6 = Color(0xFF899d31);
  static const green7 = Color(0xFFb9c24b);
  static const white = Color(0xFFD9E1F1);

  static const blue1 = Color(0xFF487070);
  static const blue2 = Color(0xFF18333d);
  static const blue3 = Color(0xFF0b1e26);

  static const gradientMain = LinearGradient(
    colors: [darkGreen, green1, green2, green3],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSoft = LinearGradient(
    colors: [green1, green5],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.darkGreen,
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}