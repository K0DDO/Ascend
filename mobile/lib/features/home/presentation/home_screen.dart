import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_button.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../core/widgets/ascend_liquid_glass.dart';
import '../../../core/widgets/ascend_metric_row.dart';
import '../../../core/widgets/ascend_screen_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../progress/application/progress_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    final auth = ref.watch(authControllerProvider);
    final progressAsync = ref.watch(progressOverviewProvider);
    final gamificationAsync = ref.watch(gamificationOverviewProvider);

    final name = auth.user?.displayName.split(' ').first ?? (auth.isGuest ? 'Гость' : 'друг');
    final progress = progressAsync.valueOrNull;
    final gamification = gamificationAsync.valueOrNull;
    final streak = gamification?.streakDays ?? 0;
    final goal = gamification?.dailyGoalReviews ?? 24;
    final done = gamification?.dailyProgressReviews ?? 0;
    final readiness = progress?.readiness ?? 0;
    final weakAreas = progress?.weakAreas ?? const [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: AscendScreenHeader(
            title: 'Доброе утро, $name',
            subtitle: 'Продолжай закреплять материал курса',
            trailing: _StreakChip(days: streak),
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
                      '$done / $goal',
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
                      onPressed: () => context.go('/learn'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: theme.spacing.lg),
              Text('Слабые места', style: text.titleLarge),
              SizedBox(height: theme.spacing.sm),
              if (weakAreas.isEmpty)
                Text(
                  'Пока мало данных — пройди несколько карточек.',
                  style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                )
              else
                ...weakAreas.take(5).map(
                      (area) => AscendMetricRow(
                        label: area.topicTitle,
                        value: '${(area.mastery * 100).round()}%',
                        accent: area.mastery < 0.7 ? theme.colors.error : theme.colors.success,
                      ),
                    ),
              SizedBox(height: theme.spacing.lg),
              AscendGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Готовность к Mock Interview',
                      style: text.labelLarge?.copyWith(color: theme.colors.muted),
                    ),
                    SizedBox(height: theme.spacing.sm),
                    _ReadinessBar(value: readiness),
                    SizedBox(height: theme.spacing.xs),
                    Text(
                      '${(readiness * 100).round()}%',
                      style: text.titleMedium,
                    ),
                    SizedBox(height: theme.spacing.md),
                    AscendGlassButton(
                      label: 'Запустить AI Interview',
                      icon: Icons.record_voice_over_rounded,
                      onPressed: () => context.push('/ai-interview'),
                    ),
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
