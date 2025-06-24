import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF131313),
      colorScheme: const ColorScheme.dark().copyWith(
        surface: const Color(0xFF1C1C1E),
        primary: const Color(0xFFEFD9B0),
        onSurface: const Color(0xFF8F8F8F),
        surfaceContainerHighest: const Color(0xFF242424), // for bottom navigation bar
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
        const CustomColors(
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
          almond2: Color(0xFFE9CA91),
          onSurfaceDim: Color(0xFF565656),
          onSurfaceMuted: Color(0xFF646464),
          onSurfaceSubtle: Color(0xFF474747),
          primarySubtle: Color(0xFF1A1815),
          primaryMuted: Color(0xFF4D4436),
          primaryDim: Color(0xFF968256),
          overlayLight: Color(0xFF0D0D0D),
          overlayMedium: Color(0xFF1A1A1A),
          overlayShadow: Color(0xFF333333),
          highlightSubtle: Color(0xFF1A1A1A),
          dropdownBackground: Color(0xFF2C2C2E),
          dropdownItemPressed: Color(0xFF1A1A1A),
          dropdownBorder: Color(0xFF1A1A1A),
          dropdownText: Color(0xFFFFFFFF),
          dropdownIcon: Color(0xFFFFFFFF),
          modalShadow: Color(0x66000000),
          cancelButtonBackground: Color(0x40000000),
          waveformColor: Color(0xCCEFD9B0),
          microphoneShadow: Color(0x4DEFD9B0),
          buttonShadow: Color(0x1A000000), // 10% black shadow for idle state
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
    required this.almond2,
    required this.onSurfaceDim,
    required this.onSurfaceMuted,
    required this.onSurfaceSubtle,
    required this.primarySubtle,
    required this.primaryMuted,
    required this.primaryDim,
    required this.overlayLight,
    required this.overlayMedium,
    required this.overlayShadow,
    required this.highlightSubtle,
    required this.dropdownBackground,
    required this.dropdownItemPressed,
    required this.dropdownBorder,
    required this.dropdownText,
    required this.dropdownIcon,
    required this.modalShadow,
    required this.cancelButtonBackground,
    required this.waveformColor,
    required this.microphoneShadow,
    required this.buttonShadow,
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
  final Color almond2;
  final Color onSurfaceDim;
  final Color onSurfaceMuted;
  final Color onSurfaceSubtle;
  final Color primarySubtle;
  final Color primaryMuted;
  final Color primaryDim;
  final Color overlayLight;
  final Color overlayMedium;
  final Color overlayShadow;
  final Color highlightSubtle;
  final Color dropdownBackground;
  final Color dropdownItemPressed;
  final Color dropdownBorder;
  final Color dropdownText;
  final Color dropdownIcon;
  final Color modalShadow;
  final Color cancelButtonBackground;
  final Color waveformColor;
  final Color microphoneShadow;
  final Color buttonShadow;

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
    Color? almond2,
    Color? onSurfaceDim,
    Color? onSurfaceMuted,
    Color? onSurfaceSubtle,
    Color? primarySubtle,
    Color? primaryMuted,
    Color? primaryDim,
    Color? overlayLight,
    Color? overlayMedium,
    Color? overlayShadow,
    Color? highlightSubtle,
    Color? dropdownBackground,
    Color? dropdownItemPressed,
    Color? dropdownBorder,
    Color? dropdownText,
    Color? dropdownIcon,
    Color? modalShadow,
    Color? cancelButtonBackground,
    Color? waveformColor,
    Color? microphoneShadow,
    Color? buttonShadow,
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
      almond2: almond2 ?? this.almond2,
      onSurfaceDim: onSurfaceDim ?? this.onSurfaceDim,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      onSurfaceSubtle: onSurfaceSubtle ?? this.onSurfaceSubtle,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      primaryDim: primaryDim ?? this.primaryDim,
      overlayLight: overlayLight ?? this.overlayLight,
      overlayMedium: overlayMedium ?? this.overlayMedium,
      overlayShadow: overlayShadow ?? this.overlayShadow,
      highlightSubtle: highlightSubtle ?? this.highlightSubtle,
      dropdownBackground: dropdownBackground ?? this.dropdownBackground,
      dropdownItemPressed: dropdownItemPressed ?? this.dropdownItemPressed,
      dropdownBorder: dropdownBorder ?? this.dropdownBorder,
      dropdownText: dropdownText ?? this.dropdownText,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      modalShadow: modalShadow ?? this.modalShadow,
      cancelButtonBackground: cancelButtonBackground ?? this.cancelButtonBackground,
      waveformColor: waveformColor ?? this.waveformColor,
      microphoneShadow: microphoneShadow ?? this.microphoneShadow,
      buttonShadow: buttonShadow ?? this.buttonShadow,
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
      almond2: Color.lerp(almond2, other.almond2, t)!,
      onSurfaceDim: Color.lerp(onSurfaceDim, other.onSurfaceDim, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      onSurfaceSubtle: Color.lerp(onSurfaceSubtle, other.onSurfaceSubtle, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      overlayLight: Color.lerp(overlayLight, other.overlayLight, t)!,
      overlayMedium: Color.lerp(overlayMedium, other.overlayMedium, t)!,
      overlayShadow: Color.lerp(overlayShadow, other.overlayShadow, t)!,
      highlightSubtle: Color.lerp(highlightSubtle, other.highlightSubtle, t)!,
      dropdownBackground: Color.lerp(dropdownBackground, other.dropdownBackground, t)!,
      dropdownItemPressed: Color.lerp(dropdownItemPressed, other.dropdownItemPressed, t)!,
      dropdownBorder: Color.lerp(dropdownBorder, other.dropdownBorder, t)!,
      dropdownText: Color.lerp(dropdownText, other.dropdownText, t)!,
      dropdownIcon: Color.lerp(dropdownIcon, other.dropdownIcon, t)!,
      modalShadow: Color.lerp(modalShadow, other.modalShadow, t)!,
      cancelButtonBackground: Color.lerp(cancelButtonBackground, other.cancelButtonBackground, t)!,
      waveformColor: Color.lerp(waveformColor, other.waveformColor, t)!,
      microphoneShadow: Color.lerp(microphoneShadow, other.microphoneShadow, t)!,
      buttonShadow: Color.lerp(buttonShadow, other.buttonShadow, t)!,
    );
  }
} 
