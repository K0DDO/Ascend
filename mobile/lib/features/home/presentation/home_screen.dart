import 'package:flutter/material.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_button.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../core/widgets/ascend_liquid_glass.dart';
import '../../../core/widgets/ascend_metric_row.dart';
import '../../../core/widgets/ascend_screen_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: AscendScreenHeader(
            title: 'Доброе утро, Андрей',
            subtitle: 'Продолжай закреплять материал курса',
            trailing: _StreakChip(days: 14),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            theme.spacing.lg,
            0,
            theme.spacing.lg,
            theme.spacing.hotbarContentInset,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AscendGlassCard(
                strong: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Цель на сегодня', style: text.labelLarge),
                    SizedBox(height: theme.spacing.xs),
                    Text(
                      '24',
                      style: text.displaySmall?.copyWith(fontSize: 36, height: 1.08),
                    ),
                    Text(
                      'карточки',
                      style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                    ),
                    SizedBox(height: theme.spacing.md),
                    AscendGlassButton(
                      label: 'Начать обучение',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: theme.spacing.lg),
              Text('Слабые места', style: text.titleLarge),
              SizedBox(height: theme.spacing.sm),
              AscendMetricRow(label: 'AsyncIO', value: '61%', accent: theme.colors.error),
              AscendMetricRow(label: 'PostgreSQL', value: '73%', accent: theme.colors.warning),
              AscendMetricRow(label: 'Python', value: '94%', accent: theme.colors.success),
              SizedBox(height: theme.spacing.lg),
              Text('Прогресс по курсу', style: text.titleLarge),
              SizedBox(height: theme.spacing.sm),
              AscendMetricRow(label: 'Python', value: '94%', accent: theme.colors.primary),
              AscendMetricRow(label: 'PostgreSQL', value: '73%', accent: theme.colors.primary),
              AscendMetricRow(label: 'FastAPI', value: '61%', accent: theme.colors.primary),
              SizedBox(height: theme.spacing.lg),
              AscendGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Следующая цель',
                      style: text.labelLarge?.copyWith(color: theme.colors.muted),
                    ),
                    SizedBox(height: theme.spacing.xxs),
                    Text('Закрыть AsyncIO', style: text.titleLarge),
                    SizedBox(height: theme.spacing.md),
                    Text('Готовность к Mock Interview', style: text.bodyMedium),
                    SizedBox(height: theme.spacing.sm),
                    _ReadinessBar(value: 0.82),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;

    return AscendLiquidGlass(
      radius: theme.radius.pill,
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: theme.colors.warning, size: 18),
          SizedBox(width: theme.spacing.xxs),
          Text(
            '$days дн.',
            style: theme.typography.textTheme.labelLarge?.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ReadinessBar extends StatelessWidget {
  const _ReadinessBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radius.pill),
      child: Stack(
        children: [
          Container(
            height: 10,
            color: theme.colors.border.withValues(alpha: 0.18),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: theme.colors.accentGradient,
                borderRadius: BorderRadius.circular(theme.radius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
