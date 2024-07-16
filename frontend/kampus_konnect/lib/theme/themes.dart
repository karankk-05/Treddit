import 'package:flutter/material.dart';

class gradients {
  static const Gradient login = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(111, 77, 80, 80), // Very Dark Gray
        Color.fromARGB(255, 0, 0, 0),
      ]);
}

class appthemes {
  static final ThemeData lighttheme = ThemeData(
      colorScheme: const ColorScheme(
    primary: Color.fromARGB(255, 183, 255, 0),
    primaryContainer: Colors.white,
    onPrimary: Color.fromARGB(255, 0, 0, 0),
    onPrimaryContainer: Colors.white,
    secondary: Color.fromARGB(255, 0, 251, 255),
    onSecondary: Color.fromRGBO(0, 0, 0, 0.831),
    secondaryContainer: Color.fromARGB(255, 0, 0, 0),
    onSecondaryContainer: Color.fromARGB(255, 183, 255, 0),
    surface: Color.fromARGB(255, 201, 201, 199),
    onSurface: Color.fromARGB(255, 0, 0, 0),
    error: Colors.red,
    onError: Colors.black,
    brightness: Brightness.light,
  ));
}
