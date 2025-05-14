import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF131313),
      colorScheme: const ColorScheme.dark().copyWith(
        surface: Color(0xFF1C1C1E),
        primary: Color(0xFFE8D8B9),
        onSurface: Color(0xFF8F8F8F),
        surfaceContainerHighest: Color(0xFF242424), // for bottom navigation bar
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE8D8B9),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF8F8F8F),
        ),
      ),
      extensions: [
        CustomColors(
          cardBackground: Color(0xFF242424),
          categoryCardBackground: Color(0xFF1C1C1E),
          iconBackground: Color(0xFF2C2C2E),
          aquamarine: Color(0xFF77FBAD),
          lightBlue: Color(0xFF6EDAFD),
          lightYellow: Color(0xFFFAFB62),
          orange: Color(0xFFF5B722),
          lightPink: Color(0xFFFFE7E5),
          darkGreen: Color(0xFF79B79F),
          lightGray: Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.cardBackground,
    required this.categoryCardBackground,
    required this.iconBackground,
    required this.aquamarine,
    required this.lightBlue,
    required this.lightYellow,
    required this.orange,
    required this.lightPink,
    required this.darkGreen,
    required this.lightGray,
  });

  final Color cardBackground;
  final Color categoryCardBackground;
  final Color iconBackground;
  final Color aquamarine;
  final Color lightBlue;
  final Color lightYellow;
  final Color orange;
  final Color lightPink;
  final Color darkGreen;
  final Color lightGray;

  @override
  CustomColors copyWith({
    Color? cardBackground,
    Color? categoryCardBackground,
    Color? iconBackground,
    Color? aquamarine,
    Color? lightBlue,
    Color? lightYellow,
    Color? orange,
    Color? lightPink,
    Color? darkGreen,
    Color? lightGray,
  }) {
    return CustomColors(
      cardBackground: cardBackground ?? this.cardBackground,
      categoryCardBackground: categoryCardBackground ?? this.categoryCardBackground,
      iconBackground: iconBackground ?? this.iconBackground,
      aquamarine: aquamarine ?? this.aquamarine,
      lightBlue: lightBlue ?? this.lightBlue,
      lightYellow: lightYellow ?? this.lightYellow,
      orange: orange ?? this.orange,
      lightPink: lightPink ?? this.lightPink,
      darkGreen: darkGreen ?? this.darkGreen,
      lightGray: lightGray ?? this.lightGray,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      categoryCardBackground: Color.lerp(categoryCardBackground, other.categoryCardBackground, t)!,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t)!,
      aquamarine: Color.lerp(aquamarine, other.aquamarine, t)!,
      lightBlue: Color.lerp(lightBlue, other.lightBlue, t)!,
      lightYellow: Color.lerp(lightYellow, other.lightYellow, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      lightPink: Color.lerp(lightPink, other.lightPink, t)!,
      darkGreen: Color.lerp(darkGreen, other.darkGreen, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t)!,
    );
  }
} 