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
    primary: Color.fromARGB(255, 183, 255, 0), //used
    onPrimary: Color.fromARGB(255, 0, 0, 0), //used
    primaryContainer: Colors.white, //used
    onPrimaryContainer: Color.fromARGB(255, 0, 0, 0), //used
    secondary: Color.fromARGB(255, 0, 251, 255),
    onSecondary: Colors.white, //used
    secondaryContainer: Color.fromARGB(255, 0, 0, 0), //used
    onSecondaryContainer: Color.fromARGB(255, 183, 255, 0), //used
    surface: Color.fromARGB(255, 245, 245, 245), //used
    onSurface: Color.fromARGB(255, 0, 0, 0),
    error: Colors.red,
    onError: Colors.black,
    brightness: Brightness.light,
  ));
}
