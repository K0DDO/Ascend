import 'package:flutter/material.dart';

import '../theme/ascend_theme.dart';

/// Solid elevated row — Subbery GlassPaymentRow pattern (not full glass).
class AscendMetricRow extends StatelessWidget {
  const AscendMetricRow({
    super.key,
    required this.label,
    required this.value,
    this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final accentColor = accent ?? theme.colors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radius.lg),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: theme.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(theme.radius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.md,
                vertical: theme.spacing.sm + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(theme.radius.lg),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.typography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.typography.textTheme.titleMedium?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
