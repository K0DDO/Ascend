import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ascend_glass.dart';
import '../theme/ascend_theme.dart';
import '../theme/glass_effect_provider.dart';

/// Matte-glass surface — single backdrop pass, Subbery-style recipe.
class AscendLiquidGlass extends StatelessWidget {
  const AscendLiquidGlass({
    super.key,
    required this.child,
    this.radius = 28,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.strong = false,
    this.progress = 1,
    this.strengthOverride,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool strong;
  final double progress;
  final double? strengthOverride;

  static final Map<double, ImageFilter> _blurCache = {};

  static ImageFilter _blurFilter(double sigma) {
    final key = (sigma * 2).round() / 2;
    return _blurCache.putIfAbsent(key, () => ImageFilter.blur(sigmaX: key, sigmaY: key));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final strength = (strengthOverride ?? AscendGlassEffectScope.of(context)).clamp(0.0, 1.0);
    final tokens = AscendGlassTokens.resolve(
      palette: theme.colors,
      brightness: theme.brightness,
      strong: strong,
      strength: strength,
      progress: progress,
    );
    final borderRadius = BorderRadius.circular(radius);

    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor,
              blurRadius: tokens.shadowBlur,
              offset: Offset(0, tokens.shadowOffsetY),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: _blurFilter(tokens.blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: tokens.fill,
                border: Border.all(color: tokens.border, width: theme.glass.borderWidth),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.alphaBlend(tokens.topTint, tokens.fill),
                    tokens.fill,
                    Color.alphaBlend(tokens.bottomTint, tokens.fill),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Legacy alias — prefer [AscendLiquidGlass] or [AscendGlassCard].
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
    return AscendLiquidGlass(
      radius: radius,
      strong: strong,
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}
