import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 48, 48, 48),
          
          surface: const Color.fromARGB(255, 246, 246, 246), 
        ),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 48, 48, 48),
          brightness: Brightness.dark,
          // Customize dark theme colors if needed
          // surface: const Color.fromARGB(255, 18, 18, 18), // Example customization
        ),
        useMaterial3: true,
      );
}
