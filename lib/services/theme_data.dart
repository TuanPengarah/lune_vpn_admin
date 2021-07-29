import 'package:flutter/material.dart';

class MyThemes {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        brightness: Brightness.dark,
      ),
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        brightness: Brightness.dark,
        backgroundColor: Colors.teal,
      ),
      brightness: Brightness.dark,
      primaryColor: Colors.teal,
      primarySwatch: Colors.teal,
    );
  }
}
