import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      secondary: Colors.teal,
      tertiary: Colors.green,
    ),
    useMaterial3: true,
  );
}