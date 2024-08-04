import 'package:flutter/material.dart';

class gradients {
  static const Gradient login = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(109, 24, 183, 27), // Very Dark Gray
        Color.fromARGB(108, 222, 230, 227), // Very Dark Gray
      ]);
}

class appthemes {
  static final ThemeData lighttheme = ThemeData(
      colorScheme: const ColorScheme(
          primary: Color.fromARGB(255, 50, 202, 0), //used
          onPrimary: Color.fromARGB(255, 0, 0, 0), //used
          primaryContainer: Colors.white, //used
          onPrimaryContainer: Color.fromARGB(255, 0, 0, 0), //used
          secondary: Color.fromARGB(255, 0, 251, 255),
          onSecondary: Colors.white, //used
          secondaryContainer: Color.fromARGB(255, 0, 0, 0), //used
          onSecondaryContainer: Color.fromARGB(255, 50, 202, 0), //used
          surface: Color.fromARGB(255, 245, 245, 245), //used
          onSurface: Color.fromARGB(255, 0, 0, 0),
          error: Colors.red,
          onError: Colors.black,
          brightness: Brightness.light,
          surfaceContainerHighest: Color.fromARGB(219, 216, 213, 213)));
}
