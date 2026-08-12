import 'package:flutter/material.dart';

import '../theme/ascend_theme.dart';

class AscendScreenHeader extends StatelessWidget {
  const AscendScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        theme.spacing.lg,
        theme.spacing.lg,
        theme.spacing.lg,
        theme.spacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.headlineMedium),
                if (subtitle case final subtitle?) ...[
                  SizedBox(height: theme.spacing.xxs),
                  Text(
                    subtitle,
                    style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
