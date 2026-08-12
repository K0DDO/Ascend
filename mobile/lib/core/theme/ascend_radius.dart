import 'package:flutter/foundation.dart';

@immutable
class AscendRadius {
  const AscendRadius({
    this.sm = 14,
    this.md = 20,
    this.lg = 28,
    this.xl = 36,
    this.pill = 999,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  static const standard = AscendRadius();
}
