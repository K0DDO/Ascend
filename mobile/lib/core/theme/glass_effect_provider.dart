import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final glassEffectStrengthProvider = StateProvider<double>((ref) => 0.55);

class AscendGlassEffectScope extends InheritedWidget {
  const AscendGlassEffectScope({
    required this.strength,
    required super.child,
    super.key,
  });

  final double strength;

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AscendGlassEffectScope>()
            ?.strength ??
        0.55;
  }

  @override
  bool updateShouldNotify(covariant AscendGlassEffectScope oldWidget) {
    return oldWidget.strength != strength;
  }
}
