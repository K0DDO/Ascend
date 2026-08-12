import 'package:flutter/material.dart';

import '../theme/ascend_theme.dart';

class AscendBackground extends StatelessWidget {
  const AscendBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final colors = theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.background, colors.backgroundEnd, colors.secondary],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowOrb(color: colors.glow.withValues(alpha: 0.35), size: 220),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _GlowOrb(color: colors.primary.withValues(alpha: 0.18), size: 180),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
