import 'package:flutter/material.dart';

import '../../../../core/theme/ascend_theme.dart';
import '../../../../core/widgets/ascend_glass_card.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.lg,
              theme.spacing.xl,
              theme.spacing.lg,
              theme.spacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.headlineMedium),
                SizedBox(height: theme.spacing.xs),
                Text(
                  subtitle,
                  style: text.bodyLarge?.copyWith(color: theme.colors.muted),
                ),
                SizedBox(height: theme.spacing.xl),
                AscendGlassCard(
                  strong: true,
                  child: child,
                ),
                if (footer != null) ...[
                  SizedBox(height: theme.spacing.lg),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}
