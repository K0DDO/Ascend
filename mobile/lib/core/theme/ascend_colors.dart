import 'package:flutter/material.dart';

@immutable
class AscendColorPalette {
  const AscendColorPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.muted,
    required this.background,
    required this.backgroundEnd,
    required this.backgroundAccent,
    required this.surface,
    required this.surfaceContainerHigh,
    required this.glass,
    required this.glassStrong,
    required this.border,
    required this.glow,
    required this.foreground,
    required this.onPrimary,
  });

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color tertiary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color muted;
  final Color background;
  final Color backgroundEnd;
  final Color backgroundAccent;
  final Color surface;
  final Color surfaceContainerHigh;
  final Color glass;
  final Color glassStrong;
  final Color border;
  final Color glow;
  final Color foreground;
  final Color onPrimary;

  static const Color accentSeed = Color(0xFFE67F73);

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryLight, primary, primaryDark],
      );

  factory AscendColorPalette.light({Color accent = accentSeed}) {
    final primary = accent;
    final primaryLight = _shiftLightness(primary, 0.12);
    final primaryDark = _shiftLightness(primary, -0.14);
    return AscendColorPalette(
      primary: primary,
      primaryLight: primaryLight,
      primaryDark: primaryDark,
      secondary: Color.alphaBlend(primary.withValues(alpha: 0.18), const Color(0xFFF0E4DE)),
      tertiary: Color.alphaBlend(primaryLight.withValues(alpha: 0.16), const Color(0xFFE8D9D4)),
      success: const Color(0xFF6F9F7C),
      warning: const Color(0xFFC3975B),
      error: const Color(0xFFC56F75),
      info: primaryLight,
      muted: Color.alphaBlend(primary.withValues(alpha: 0.06), const Color(0xFF665A58)),
      background: Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFFF0E4DE)),
      backgroundEnd: Color.alphaBlend(primary.withValues(alpha: 0.06), const Color(0xFFE8D9D4)),
      backgroundAccent: Color.alphaBlend(primary.withValues(alpha: 0.1), const Color(0xFFE8D9D4)),
      surface: Color.alphaBlend(primary.withValues(alpha: 0.05), const Color(0xFFF4E9E5)),
      surfaceContainerHigh: Color.alphaBlend(primary.withValues(alpha: 0.04), const Color(0xFFE9DAD5)),
      glass: Color.alphaBlend(primary.withValues(alpha: 0.14), const Color(0xCFEFE4E0)),
      glassStrong: Color.alphaBlend(primary.withValues(alpha: 0.12), const Color(0xE6F3E9E5)),
      border: primary.withValues(alpha: 0.28),
      glow: primary.withValues(alpha: 0.3),
      foreground: const Color(0xFF291C1C),
      onPrimary: _onPrimaryForeground(primary),
    );
  }

  factory AscendColorPalette.dark({Color accent = accentSeed}) {
    final primary = _shiftLightness(accent, 0.05);
    final primaryLight = _shiftLightness(primary, 0.12);
    final primaryDark = _shiftLightness(primary, -0.14);
    return AscendColorPalette(
      primary: primary,
      primaryLight: primaryLight,
      primaryDark: primaryDark,
      secondary: primary.withValues(alpha: 0.24),
      tertiary: primaryLight.withValues(alpha: 0.18),
      success: const Color(0xFF7AA988),
      warning: const Color(0xFFC9A066),
      error: const Color(0xFFCF7B81),
      info: primaryLight,
      muted: Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFFBAAFB0)),
      background: Color.alphaBlend(primary.withValues(alpha: 0.1), const Color(0xFF171519)),
      backgroundEnd: Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFF211B22)),
      backgroundAccent: Color.alphaBlend(primary.withValues(alpha: 0.12), const Color(0xFF211B22)),
      surface: const Color(0xFF2A222C),
      surfaceContainerHigh: const Color(0xFF322830),
      glass: Color.alphaBlend(primary.withValues(alpha: 0.42), const Color(0x14FFFFFF)),
      glassStrong: Color.alphaBlend(primary.withValues(alpha: 0.5), const Color(0x24FFFFFF)),
      border: primary.withValues(alpha: 0.34),
      glow: primary.withValues(alpha: 0.4),
      foreground: const Color(0xFFFFF8F5),
      onPrimary: _onPrimaryForeground(primary),
    );
  }

  AscendColorPalette lerp(AscendColorPalette other, double t) {
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AscendColorPalette(
      primary: l(primary, other.primary),
      primaryLight: l(primaryLight, other.primaryLight),
      primaryDark: l(primaryDark, other.primaryDark),
      secondary: l(secondary, other.secondary),
      tertiary: l(tertiary, other.tertiary),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      error: l(error, other.error),
      info: l(info, other.info),
      muted: l(muted, other.muted),
      background: l(background, other.background),
      backgroundEnd: l(backgroundEnd, other.backgroundEnd),
      backgroundAccent: l(backgroundAccent, other.backgroundAccent),
      surface: l(surface, other.surface),
      surfaceContainerHigh: l(surfaceContainerHigh, other.surfaceContainerHigh),
      glass: l(glass, other.glass),
      glassStrong: l(glassStrong, other.glassStrong),
      border: l(border, other.border),
      glow: l(glow, other.glow),
      foreground: l(foreground, other.foreground),
      onPrimary: l(onPrimary, other.onPrimary),
    );
  }
}

Color _shiftLightness(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.08, 0.94)).toColor();
}

Color _onPrimaryForeground(Color primary) {
  return primary.computeLuminance() > 0.55 ? const Color(0xFF211719) : const Color(0xFFFFFBFA);
}

/// Backward-compatible alias used across the app theme layer.
typedef AscendColors = AscendColorPalette;
