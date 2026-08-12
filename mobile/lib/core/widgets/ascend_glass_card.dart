import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ascend_animations.dart';
import '../theme/ascend_theme.dart';
import 'ascend_liquid_glass.dart';

class AscendGlassCard extends StatefulWidget {
  const AscendGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius,
    this.onTap,
    this.strong = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final VoidCallback? onTap;
  final bool strong;

  @override
  State<AscendGlassCard> createState() => _AscendGlassCardState();
}

class _AscendGlassCardState extends State<AscendGlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final radius = widget.radius ?? theme.radius.lg;
    final interactive = widget.onTap != null;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: AscendAnimations.standardPreset.fast,
      curve: AscendAnimations.standardPreset.standard,
      child: AscendLiquidGlass(
        margin: widget.margin,
        radius: radius,
        strong: widget.strong,
        padding: EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    widget.onTap!.call();
                  },
            onTapDown: interactive ? (_) => _setPressed(true) : null,
            onTapUp: interactive ? (_) => _setPressed(false) : null,
            onTapCancel: interactive ? () => _setPressed(false) : null,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
