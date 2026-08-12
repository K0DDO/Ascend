import 'package:flutter/foundation.dart';

@immutable
class AscendSpacing {
  const AscendSpacing({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
    this.hotbarContentInset = 128,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double hotbarContentInset;

  static const standard = AscendSpacing();
}
