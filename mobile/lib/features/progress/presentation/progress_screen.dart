import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../core/widgets/ascend_metric_row.dart';
import '../../../core/widgets/ascend_screen_header.dart';
import '../application/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    final overviewAsync = ref.watch(progressOverviewProvider);
    final gamificationAsync = ref.watch(gamificationOverviewProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: AscendScreenHeader(
            title: 'Прогресс',
            subtitle: 'Retention, слабые места и готовность',
          ),
        ),
        overviewAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Text(
                'Не удалось загрузить прогресс.',
                style: text.bodyLarge?.copyWith(color: theme.colors.error),
              ),
            ),
          ),
          data: (overview) => SliverPadding(
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
                      Text('Готовность', style: text.labelLarge),
                      SizedBox(height: theme.spacing.xs),
                      Text(
                        '${(overview.readiness * 100).round()}%',
                        style: text.displaySmall?.copyWith(fontSize: 36, height: 1.08),
                      ),
                      SizedBox(height: theme.spacing.sm),
                      _ReadinessBar(value: overview.readiness),
                    ],
                  ),
                ),
                SizedBox(height: theme.spacing.lg),
                Text('Ключевые метрики', style: text.titleLarge),
                SizedBox(height: theme.spacing.sm),
                AscendMetricRow(label: 'Всего ответов', value: '${overview.totalReviews}'),
                AscendMetricRow(
                  label: 'Точность (Знаю)',
                  value: '${(overview.knowRate * 100).round()}%',
                  accent: theme.colors.success,
                ),
                if (gamificationAsync.valueOrNull case final g?) ...[
                  AscendMetricRow(
                    label: 'Streak',
                    value: '${g.streakDays} дн.',
                    accent: theme.colors.warning,
                  ),
                  AscendMetricRow(
                    label: 'XP (всего)',
                    value: '${g.xpTotal}',
                    accent: theme.colors.primary,
                  ),
                  AscendMetricRow(
                    label: 'Daily goal',
                    value: '${g.dailyProgressReviews}/${g.dailyGoalReviews}',
                    accent: theme.colors.info,
                  ),
                ],
                SizedBox(height: theme.spacing.lg),
                Text('Слабые места', style: text.titleLarge),
                SizedBox(height: theme.spacing.sm),
                if (overview.weakAreas.isEmpty)
                  AscendGlassCard(
                    child: Text(
                      'Пока недостаточно данных. Пройдите несколько сессий.',
                      style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                    ),
                  )
                else
                  for (final weak in overview.weakAreas)
                    AscendMetricRow(
                      label: weak.topicTitle,
                      value: '${(weak.mastery * 100).round()}%',
                      accent: weak.mastery < 0.6
                          ? theme.colors.error
                          : weak.mastery < 0.8
                              ? theme.colors.warning
                              : theme.colors.success,
                    ),
                SizedBox(height: theme.spacing.lg),
                Text('Активность (14 дней)', style: text.titleLarge),
                SizedBox(height: theme.spacing.sm),
                AscendGlassCard(
                  child: _ActivityHeatstrip(
                    values: overview.activity.map((d) => d.reviews).toList(),
                  ),
                ),
                if (gamificationAsync.valueOrNull case final gamification?) ...[
                  SizedBox(height: theme.spacing.lg),
                  Text('Достижения', style: text.titleLarge),
                  SizedBox(height: theme.spacing.sm),
                  for (final achievement in gamification.achievements)
                    AscendGlassCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.md,
                        vertical: theme.spacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            achievement.unlocked
                                ? Icons.verified_rounded
                                : Icons.lock_outline_rounded,
                            color: achievement.unlocked ? theme.colors.success : theme.colors.muted,
                          ),
                          SizedBox(width: theme.spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(achievement.title, style: text.titleMedium),
                                SizedBox(height: theme.spacing.xxs),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(theme.radius.pill),
                                  child: LinearProgressIndicator(
                                    value: achievement.progress.clamp(0, 1),
                                    minHeight: 6,
                                    backgroundColor: theme.colors.border.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation(
                                      achievement.unlocked ? theme.colors.success : theme.colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ]),
            ),
          ),
        ),
      ],
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

class _ActivityHeatstrip extends StatelessWidget {
  const _ActivityHeatstrip({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b).clamp(1, 100000);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final value in values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.xxs / 2),
              child: Container(
                height: 8 + 30 * (value / max),
                decoration: BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.18 + 0.7 * (value / max)),
                  borderRadius: BorderRadius.circular(theme.radius.sm),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
