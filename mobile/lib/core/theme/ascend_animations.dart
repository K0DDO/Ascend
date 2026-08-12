import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';

@immutable
class AscendAnimations {
  const AscendAnimations({
    this.fast = const Duration(milliseconds: 130),
    this.normal = const Duration(milliseconds: 240),
    this.slow = const Duration(milliseconds: 320),
    this.standard = Curves.easeOutCubic,
    this.bounceBack = Curves.easeOutBack,
  });

  final Duration fast;
  final Duration normal;
  final Duration slow;
  final Curve standard;
  final Curve bounceBack;

  static const standardPreset = AscendAnimations();
}
