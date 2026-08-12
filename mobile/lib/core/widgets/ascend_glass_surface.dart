import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ascend_theme.dart';

class AscendGlassSurface extends StatelessWidget {
  const AscendGlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = 28,
    this.strong = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final glass = theme.glass;
    final colors = theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.12 : 0.08),
            blurRadius: glass.shadowBlur,
            offset: Offset(0, glass.shadowOffsetY),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: glass.blurSigma,
            sigmaY: glass.blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: glass.fillGradient(colors),
              border: Border.all(
                color: colors.border.withValues(alpha: strong ? 0.45 : 0.32),
                width: glass.borderWidth,
              ),
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
