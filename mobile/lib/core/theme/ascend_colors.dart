import 'package:flutter/material.dart';

@immutable
class AscendColors {
  const AscendColors({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.muted,
    required this.background,
    required this.backgroundEnd,
    required this.surface,
    required this.glass,
    required this.border,
    required this.glow,
    required this.foreground,
  });

  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color muted;
  final Color background;
  final Color backgroundEnd;
  final Color surface;
  final Color glass;
  final Color border;
  final Color glow;
  final Color foreground;

  static const Color accentSeed = Color(0xFFE67F73);

  factory AscendColors.light({Color accent = accentSeed}) {
    final primary = accent;
    return AscendColors(
      primary: primary,
      secondary: Color.alphaBlend(primary.withValues(alpha: 0.18), const Color(0xFFF0E4DE)),
      success: const Color(0xFF6F9F7C),
      warning: const Color(0xFFC3975B),
      error: const Color(0xFFC56F75),
      info: _shiftLightness(primary, 0.12),
      muted: Color.alphaBlend(primary.withValues(alpha: 0.06), const Color(0xFF665A58)),
      background: Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFFF0E4DE)),
      backgroundEnd: Color.alphaBlend(primary.withValues(alpha: 0.06), const Color(0xFFE8D9D4)),
      surface: Color.alphaBlend(primary.withValues(alpha: 0.05), const Color(0xFFF4E9E5)),
      glass: Color.alphaBlend(primary.withValues(alpha: 0.11), const Color(0xCFEFE4E0)),
      border: primary.withValues(alpha: 0.28),
      glow: primary.withValues(alpha: 0.3),
      foreground: const Color(0xFF291C1C),
    );
  }

  factory AscendColors.dark({Color accent = accentSeed}) {
    final primary = _shiftLightness(accent, 0.05);
    return AscendColors(
      primary: primary,
      secondary: primary.withValues(alpha: 0.24),
      success: const Color(0xFF7AA988),
      warning: const Color(0xFFC9A066),
      error: const Color(0xFFCF7B81),
      info: _shiftLightness(primary, 0.14),
      muted: Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFFBAAFB0)),
      background: Color.alphaBlend(primary.withValues(alpha: 0.1), const Color(0xFF171519)),
      backgroundEnd: Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFF211B22)),
      surface: const Color(0xFF2A222C),
      glass: Color.alphaBlend(primary.withValues(alpha: 0.14), const Color(0x14FFFFFF)),
      border: primary.withValues(alpha: 0.34),
      glow: primary.withValues(alpha: 0.4),
      foreground: const Color(0xFFFFF8F5),
    );
  }

  AscendColors lerp(AscendColors other, double t) {
    return AscendColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      border: Color.lerp(border, other.border, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
    );
  }
}

Color _shiftLightness(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.08, 0.94))
      .toColor();
}
