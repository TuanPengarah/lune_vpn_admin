import 'package:flutter/material.dart';

class MyThemes {
  static final lightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      brightness: Brightness.dark,
    ),
    brightness: Brightness.light,
    primaryColor: Colors.blue,
  );
  static final darkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      brightness: Brightness.dark,
      backgroundColor: Colors.teal,
    ),
    brightness: Brightness.dark,
    primaryColor: Colors.teal,
  );
}
