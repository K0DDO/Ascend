import 'package:flutter/material.dart';

import '../../../core/theme/ascend_theme.dart';

class AscendPlaceholderTab extends StatelessWidget {
  const AscendPlaceholderTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
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
            Text(title, style: theme.typography.textTheme.headlineMedium),
            SizedBox(height: theme.spacing.sm),
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
