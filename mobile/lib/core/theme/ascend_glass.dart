import 'package:flutter/material.dart';

import 'ascend_colors.dart';

@immutable
class AscendGlass {
  const AscendGlass({
    required this.blurSigma,
    required this.borderWidth,
    required this.shadowBlur,
    required this.shadowOffsetY,
  });

  final double blurSigma;
  final double borderWidth;
  final double shadowBlur;
  final double shadowOffsetY;

  factory AscendGlass.forBrightness(Brightness brightness) {
    return AscendGlass(
      blurSigma: brightness == Brightness.dark ? 24 : 18,
      borderWidth: 0.8,
      shadowBlur: 26,
      shadowOffsetY: 10,
    );
  }

  LinearGradient fillGradient(AscendColors colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0, 0.42, 1],
      colors: [
        colors.glass.withValues(alpha: 0.92),
        colors.glass,
        Color.alphaBlend(
          colors.primary.withValues(alpha: 0.04),
          colors.glass,
        ),
      ],
    );
  }
}
