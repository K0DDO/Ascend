import 'package:flutter/material.dart';

import 'ascend_colors.dart';

@immutable
class AscendGlassTokens {
  const AscendGlassTokens({
    required this.blur,
    required this.fill,
    required this.topTint,
    required this.bottomTint,
    required this.border,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffsetY,
  });

  final double blur;
  final Color fill;
  final Color topTint;
  final Color bottomTint;
  final Color border;
  final Color shadowColor;
  final double shadowBlur;
  final double shadowOffsetY;

  factory AscendGlassTokens.resolve({
    required AscendColorPalette palette,
    required Brightness brightness,
    required bool strong,
    double strength = 0.55,
    double progress = 1,
  }) {
    final t = strength.clamp(0.0, 1.0);
    final p = progress.clamp(0.0, 1.0);
    final isDark = brightness == Brightness.dark;
    final base = strong ? palette.glassStrong : palette.glass;
    final blurBase = isDark ? 24.0 : 18.0;
    final blur = blurBase * (1 - t * 0.18);

    final targetFill = isDark
        ? palette.primary.withValues(alpha: 0.09)
        : Color.alphaBlend(
            palette.primary.withValues(alpha: 0.05),
            const Color(0xDDF0E5E1),
          );
    final fill = Color.lerp(base, targetFill, t * 0.28)!;

    final topTint = Color.lerp(
      Color.fromRGBO(255, 255, 255, isDark ? 0.055 : 0.075),
      palette.primaryLight.withValues(alpha: isDark ? 0.045 : 0.06),
      t * 0.35,
    )!;

    final bottomTint = palette.primaryDark.withValues(alpha: isDark ? 0.025 : 0.018);

    final border = Color.lerp(
      palette.border,
      palette.border.withValues(alpha: isDark ? 0.22 : 0.2),
      t * 0.3,
    )!;

    final shadowColor = Color.lerp(
      palette.primaryDark.withValues(alpha: isDark ? 0.16 : 0.1),
      palette.primaryDark.withValues(alpha: isDark ? 0.12 : 0.08),
      t * 0.2,
    )!;

    return AscendGlassTokens(
      blur: blur,
      fill: fill,
      topTint: topTint,
      bottomTint: bottomTint,
      border: border,
      shadowColor: shadowColor,
      shadowBlur: 24 + p * 4,
      shadowOffsetY: 9 + p * 2,
    );
  }
}

@immutable
class AscendGlass {
  const AscendGlass({
    required this.blurSigma,
    required this.borderWidth,
  });

  final double blurSigma;
  final double borderWidth;

  factory AscendGlass.forBrightness(Brightness brightness) {
    return AscendGlass(
      blurSigma: brightness == Brightness.dark ? 24 : 18,
      borderWidth: 0.8,
    );
  }
}
