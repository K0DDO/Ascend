import 'package:flutter/material.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_surface.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.hotbarContentInset,
        ),
        children: [
          Text('Good morning, Andrei', style: text.headlineMedium),
          SizedBox(height: theme.spacing.xs),
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: theme.colors.warning, size: 18),
              SizedBox(width: theme.spacing.xxs),
              Text('14 day streak', style: text.titleMedium?.copyWith(color: theme.colors.muted)),
            ],
          ),
          SizedBox(height: theme.spacing.lg),
          AscendGlassSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's goal", style: text.labelLarge),
                SizedBox(height: theme.spacing.xs),
                Text('24 cards', style: text.displaySmall?.copyWith(fontSize: 32)),
                SizedBox(height: theme.spacing.md),
                _PrimaryButton(label: 'Start learning', onPressed: () {}),
              ],
            ),
          ),
          SizedBox(height: theme.spacing.md),
          Text('Weak areas', style: text.titleLarge),
          SizedBox(height: theme.spacing.sm),
          _MetricRow(label: 'AsyncIO', value: '61%', accent: theme.colors.error),
          _MetricRow(label: 'PostgreSQL', value: '73%', accent: theme.colors.warning),
          _MetricRow(label: 'Python', value: '94%', accent: theme.colors.success),
          SizedBox(height: theme.spacing.lg),
          Text('Course progress', style: text.titleLarge),
          SizedBox(height: theme.spacing.sm),
          _MetricRow(label: 'Python', value: '94%', accent: theme.colors.primary),
          _MetricRow(label: 'PostgreSQL', value: '73%', accent: theme.colors.primary),
          _MetricRow(label: 'FastAPI', value: '61%', accent: theme.colors.primary),
          SizedBox(height: theme.spacing.lg),
          AscendGlassSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next goal', style: text.labelLarge?.copyWith(color: theme.colors.muted)),
                SizedBox(height: theme.spacing.xxs),
                Text('Close AsyncIO', style: text.titleLarge),
                SizedBox(height: theme.spacing.md),
                Text('Progress toward Mock Interview', style: text.bodyMedium),
                SizedBox(height: theme.spacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radius.pill),
                  child: LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 10,
                    backgroundColor: theme.colors.border.withValues(alpha: 0.2),
                    color: theme.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radius.pill),
          gradient: LinearGradient(
            colors: [theme.colors.primary, theme.colors.info],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colors.glow.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(theme.radius.pill),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.lg,
                vertical: 17,
              ),
              child: Center(
                child: Text(label, style: theme.typography.textTheme.labelLarge),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.sm),
      child: AscendGlassSurface(
        radius: theme.radius.md,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.typography.textTheme.titleMedium)),
            Text(
              value,
              style: theme.typography.textTheme.titleMedium?.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
