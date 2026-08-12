import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AscendTypography {
  const AscendTypography({required this.textTheme});

  final TextTheme textTheme;

  factory AscendTypography.forBrightness(Brightness brightness) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    final foreground = brightness == Brightness.dark
        ? const Color(0xFFFFF8F5)
        : const Color(0xFF291C1C);

    final theme = base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.02,
        letterSpacing: -2.2,
        color: foreground,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -1.4,
        color: foreground,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.7,
        color: foreground,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: foreground,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: foreground,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: foreground,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: foreground,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: foreground,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
    );

    return AscendTypography(textTheme: theme);
  }
}
