import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      colorScheme: const ColorScheme.dark().copyWith(
        surface: Color(0xFF1C1C1E),
        primary: Color(0xFFE8D8B9),
        onSurface: Color(0xFF8F8F8F),
        surfaceContainerHighest: Color(0xFF242424), // for bottom navigation bar
      ),
    );
  }
} 