import 'package:flutter/material.dart';

class gradients{
  static const Gradient login=LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
   colors: [
    Color.fromARGB(111, 77, 80, 80), // Very Dark Gray
    Color.fromARGB(255, 0, 0, 0),
    ]);
}
class AppColors {
  // Common colors
  static const Color primary = Colors.blue;

  // Light mode specific colors
  static const Color lightPrimary = Colors.blue;
  static const Color lightPrimaryVariant = Colors.blueAccent;
  static const Color lightSecondary = Colors.lightBlue;
  static const Color lightSecondaryVariant = Colors.lightBlueAccent;
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightError = Colors.red;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.black;
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black;
  static const Color lightOnError = Colors.white;

  // Dark mode specific colors
  static const Color darkPrimary = Color.fromARGB(255, 0, 0, 0);
  static const Color darkPrimaryVariant = Color.fromARGB(255, 36, 36, 38);
  static const Color darkSecondary = Color.fromARGB(255, 1, 22, 86);
  static const Color darkSecondaryVariant = Color.fromARGB(255, 152, 173, 183);
  static const Color darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const Color darkSurface = Colors.black;
  static const Color darkError = Colors.red;
  static const Color darkOnPrimary = Colors.black;
  static const Color darkOnSecondary = Color.fromRGBO(250, 250, 251, 0.835);
  static const Color darkOnBackground = Color.fromARGB(255, 255, 255, 255);
  static const Color darkOnSurface = Color.fromARGB(255, 88, 119, 221);
  static const Color darkOnError = Colors.black;

  //Random colors
  
}



class appthemes {
  static final ThemeData lighttheme = ThemeData(
    colorScheme: ColorScheme(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryVariant,
      secondary: AppColors.lightSecondary,
      secondaryContainer: AppColors.lightSecondaryVariant,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onSurface: AppColors.lightOnSurface,
      onBackground: AppColors.lightOnBackground,
      onError: AppColors.lightOnError,
      brightness: Brightness.light,

    ),
  );

  static final ThemeData darktheme = ThemeData(
    colorScheme: ColorScheme(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.darkPrimaryVariant,
      secondary: AppColors.darkSecondary,
      secondaryContainer: AppColors.darkSecondaryVariant,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.darkError,
      onPrimary: Color.fromARGB(255, 255, 255, 255),
      onSecondary: Color.fromARGB(210, 255, 255, 255),
      onSurface: AppColors.darkOnSurface,
      onBackground:  Color.fromARGB(255, 254, 254, 254),
      onError: AppColors.darkOnError,
      brightness: Brightness.dark,
    ),
  );
}
