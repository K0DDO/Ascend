import 'package:flutter/material.dart';

import 'ascend_animations.dart';
import 'ascend_colors.dart';
import 'ascend_glass.dart';
import 'ascend_radius.dart';
import 'ascend_spacing.dart';
import 'ascend_typography.dart';

@immutable
class AscendTheme extends ThemeExtension<AscendTheme> {
  const AscendTheme({
    required this.brightness,
    required this.colors,
    this.spacing = AscendSpacing.standard,
    this.radius = AscendRadius.standard,
    required this.typography,
    required this.glass,
    this.animations = AscendAnimations.standardPreset,
  });

  final Brightness brightness;
  final AscendColors colors;
  final AscendSpacing spacing;
  final AscendRadius radius;
  final AscendTypography typography;
  final AscendGlass glass;
  final AscendAnimations animations;

  factory AscendTheme.light({Color accent = AscendColors.accentSeed}) {
    return AscendTheme(
      brightness: Brightness.light,
      colors: AscendColors.light(accent: accent),
      typography: AscendTypography.forBrightness(Brightness.light),
      glass: AscendGlass.forBrightness(Brightness.light),
    );
  }

  factory AscendTheme.dark({Color accent = AscendColors.accentSeed}) {
    return AscendTheme(
      brightness: Brightness.dark,
      colors: AscendColors.dark(accent: accent),
      typography: AscendTypography.forBrightness(Brightness.dark),
      glass: AscendGlass.forBrightness(Brightness.dark),
    );
  }

  ThemeData toThemeData() {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      surface: colors.surface,
      onSurface: colors.foreground,
      onSurfaceVariant: colors.muted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: typography.textTheme,
      dividerColor: colors.border.withValues(alpha: 0.35),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.alphaBlend(colors.glass, colors.surface),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.md),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.md),
          borderSide: BorderSide(color: colors.border.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.md),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      extensions: [this],
    );
  }

  @override
  AscendTheme copyWith({
    Brightness? brightness,
    AscendColors? colors,
    AscendTypography? typography,
    AscendGlass? glass,
  }) {
    return AscendTheme(
      brightness: brightness ?? this.brightness,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      glass: glass ?? this.glass,
    );
  }

  @override
  AscendTheme lerp(ThemeExtension<AscendTheme>? other, double t) {
    if (other is! AscendTheme) return this;
    return AscendTheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      colors: colors.lerp(other.colors, t),
      typography: other.typography,
      glass: other.glass,
    );
  }
}

extension AscendThemeContext on BuildContext {
  AscendTheme get ascendTheme => Theme.of(this).extension<AscendTheme>()!;
}
