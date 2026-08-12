import 'package:flutter/material.dart';

import '../../../core/theme/ascend_theme.dart';

class AscendPlaceholderTab extends StatelessWidget {
  const AscendPlaceholderTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;

    if (compact) {
      return Text(
        subtitle,
        style: theme.typography.textTheme.bodyLarge?.copyWith(color: theme.colors.muted),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.hotbarContentInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: theme.colors.primary),
            SizedBox(height: theme.spacing.md),
            if (title.isNotEmpty)
              Text(title, style: theme.typography.textTheme.headlineMedium),
            if (title.isNotEmpty) SizedBox(height: theme.spacing.sm),
            Text(
              subtitle,
              style: theme.typography.textTheme.bodyLarge?.copyWith(color: theme.colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
