import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/ascend_animations.dart';
import '../theme/ascend_theme.dart';

class AscendGlassButton extends StatefulWidget {
  const AscendGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  State<AscendGlassButton> createState() => _AscendGlassButtonState();
}

class _AscendGlassButtonState extends State<AscendGlassButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final colors = theme.colors;
    final enabled = widget.onPressed != null;
    final foreground = enabled ? colors.onPrimary : colors.muted;

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radius.pill),
        gradient: enabled
            ? (_pressed
                ? LinearGradient(colors: [colors.primaryDark, colors.primary])
                : colors.accentGradient)
            : LinearGradient(
                colors: [
                  colors.muted.withValues(alpha: 0.3),
                  colors.muted.withValues(alpha: 0.2),
                ],
              ),
        border: Border.all(
          color: Colors.white.withValues(alpha: enabled ? 0.18 : 0.08),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: colors.glow.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(theme.radius.pill),
          onTap: enabled
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onPressed!.call();
                }
              : null,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.lg,
              vertical: 17,
            ),
            child: Row(
              mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon case final icon?) ...[
                  Icon(icon, size: 20, color: foreground),
                  SizedBox(width: theme.spacing.xs),
                ],
                Text(
                  widget.label,
                  style: theme.typography.textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final button = AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 100),
      curve: AscendAnimations.standardPreset.standard,
      child: surface,
    );

    return widget.expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
