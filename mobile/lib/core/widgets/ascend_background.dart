import 'package:flutter/material.dart';

import '../theme/ascend_theme.dart';

class AscendBackground extends StatelessWidget {
  const AscendBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final colors = theme.colors;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [colors.background, colors.backgroundEnd]
              : [colors.background, colors.backgroundEnd, colors.backgroundAccent],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -150,
            right: -120,
            child: _GlowOrb(
              size: 360,
              color: colors.primary,
              opacity: isDark ? 0.23 : 0.13,
            ),
          ),
          Positioned(
            bottom: -170,
            left: -150,
            child: _GlowOrb(
              size: 420,
              color: colors.secondary,
              opacity: isDark ? 0.2 : 0.11,
            ),
          ),
          if (isDark)
            Positioned(
              top: 280,
              left: -100,
              child: _GlowOrb(
                size: 280,
                color: colors.tertiary,
                opacity: 0.12,
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AscendScrollBehavior extends ScrollBehavior {
  const AscendScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
