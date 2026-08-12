import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../data/models/course_models.dart';
import '../../auth/application/auth_controller.dart';
import '../../sync/application/content_sync_service.dart';
import '../application/courses_provider.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final auth = ref.watch(authControllerProvider);

    if (auth.isGuest) {
      return const _GuestNotice();
    }

    if (!auth.isSignedIn) {
      return const _GuestNotice(message: 'Войдите, чтобы видеть доступные курсы.');
    }

    final coursesAsync = ref.watch(coursesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(coursesProvider);
        ref.invalidate(contentSyncServiceProvider);
        await ref.read(coursesProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                theme.spacing.lg,
                theme.spacing.lg,
                theme.spacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Обучение', style: theme.typography.textTheme.headlineMedium),
                  ),
                  if (coursesAsync.valueOrNull?.source == ContentDataSource.cache)
                    _Badge(
                      label: 'Офлайн',
                      icon: Icons.cloud_off_rounded,
                      muted: true,
                    ),
                ],
              ),
            ),
          ),
          coursesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.lg),
                child: Text(
                  'Не удалось загрузить курсы. Потяните вниз для повтора.',
                  style: theme.typography.textTheme.bodyLarge?.copyWith(color: theme.colors.error),
                ),
              ),
            ),
            data: (snapshot) => SliverPadding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                0,
                theme.spacing.lg,
                theme.spacing.hotbarContentInset,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = snapshot.courses[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: theme.spacing.md),
                      child: _CourseTile(course: course),
                    );
                  },
                  childCount: snapshot.courses.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestNotice extends StatelessWidget {
  const _GuestNotice({this.message = 'В демо-режиме курсы недоступны. Создайте аккаунт или войдите.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.lg),
        child: AscendGlassCard(
          child: Text(
            message,
            style: theme.typography.textTheme.bodyLarge?.copyWith(color: theme.colors.muted),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _CourseTile extends ConsumerWidget {
  const _CourseTile({required this.course});

  final CourseSummary course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;

    return AscendGlassCard(
      strong: !course.locked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(course.title, style: text.titleLarge)),
              if (course.locked)
                _Badge(
                  label: 'Заблокирован',
                  icon: Icons.lock_rounded,
                  muted: true,
                )
              else
                _Badge(
                  label: '${course.topicCount} тем',
                  icon: Icons.topic_rounded,
                ),
            ],
          ),
          if (course.description case final description?) ...[
            SizedBox(height: theme.spacing.xs),
            Text(
              description,
              style: text.bodyMedium?.copyWith(color: theme.colors.muted),
            ),
          ],
          if (!course.locked) ...[
            SizedBox(height: theme.spacing.md),
            _TopicPreview(courseId: course.id),
          ],
        ],
      ),
    );
  }
}

class _TopicPreview extends ConsumerWidget {
  const _TopicPreview({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final detailAsync = ref.watch(courseDetailProvider(courseId));

    return detailAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (_, __) => const SizedBox.shrink(),
      data: (detail) {
        if (detail == null) return const SizedBox.shrink();
        final topics = detail.sections.expand((section) => section.topics).toList();
        if (topics.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Темы', style: theme.typography.textTheme.labelLarge),
            SizedBox(height: theme.spacing.xs),
            for (final topic in topics)
              Padding(
                padding: EdgeInsets.only(bottom: theme.spacing.xs),
                child: InkWell(
                  borderRadius: BorderRadius.circular(theme.radius.sm),
                  onTap: topic.locked
                      ? null
                      : () => context.push(
                            '/learn/topic/${topic.id}',
                            extra: topic,
                          ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          topic.locked ? Icons.lock_outline_rounded : Icons.play_circle_outline_rounded,
                          size: 18,
                          color: topic.locked ? theme.colors.muted : theme.colors.primary,
                        ),
                        SizedBox(width: theme.spacing.xs),
                        Expanded(
                          child: Text(
                            topic.title,
                            style: theme.typography.textTheme.bodyMedium?.copyWith(
                              color: topic.locked ? theme.colors.muted : null,
                            ),
                          ),
                        ),
                        Text(
                          topic.locked ? 'закрыто' : '${topic.estimatedMinutes} мин',
                          style: theme.typography.textTheme.bodySmall?.copyWith(color: theme.colors.muted),
                        ),
                        SizedBox(width: theme.spacing.xs),
                        Icon(Icons.chevron_right_rounded, size: 16, color: theme.colors.muted),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon, this.muted = false});

  final String label;
  final IconData icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final color = muted ? theme.colors.muted : theme.colors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm, vertical: theme.spacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.radius.pill),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: theme.spacing.xs),
          Text(label, style: theme.typography.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
