import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_button.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../data/models/course_models.dart';
import '../application/topic_provider.dart';

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.topic});

  final TopicSummary topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final cardsAsync = ref.watch(topicCardsProvider(topic.id));
    final progressAsync = ref.watch(topicProgressProvider(topic.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(topic.title, style: theme.typography.textTheme.titleLarge),
            centerTitle: false,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                theme.spacing.sm,
                theme.spacing.lg,
                theme.spacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (topic.description case final desc?) ...[
                    Text(
                      desc,
                      style: theme.typography.textTheme.bodyMedium
                          ?.copyWith(color: theme.colors.muted),
                    ),
                    SizedBox(height: theme.spacing.md),
                  ],
                  progressAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (progress) {
                      if (progress == null) return const SizedBox.shrink();
                      return _ProgressBar(
                        knowCount: progress.knowCount,
                        totalCards: progress.totalCards,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          cardsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Не удалось загрузить карточки.',
                  style: theme.typography.textTheme.bodyLarge
                      ?.copyWith(color: theme.colors.error),
                ),
              ),
            ),
            data: (cards) {
              if (cards.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(theme.spacing.lg),
                      child: Text(
                        'Карточки ещё не добавлены в эту тему.',
                        style: theme.typography.textTheme.bodyLarge
                            ?.copyWith(color: theme.colors.muted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  theme.spacing.lg,
                  0,
                  theme.spacing.lg,
                  theme.spacing.hotbarContentInset + theme.spacing.lg,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Consumer(
                      builder: (context, ref, _) {
                        final queueAsync = ref.watch(studyQueueProvider(topic.id));
                        final dueAsync = ref.watch(dueQueueProvider(topic.id));
                        final dueCount = dueAsync.valueOrNull?.items.length ?? cards.length;
                        return AscendGlassButton(
                          label: 'Учить сейчас  ($dueCount)',
                          icon: Icons.play_arrow_rounded,
                          onPressed: queueAsync.isLoading
                              ? null
                              : () {
                                  final queue = queueAsync.valueOrNull ?? cards;
                                  context.push(
                                    '/learn/topic/${topic.id}/cards',
                                    extra: {'cards': queue, 'topic': topic},
                                  );
                                },
                        );
                      },
                    ),
                    SizedBox(height: theme.spacing.lg),
                    Text(
                      'Карточки',
                      style: theme.typography.textTheme.labelLarge,
                    ),
                    SizedBox(height: theme.spacing.sm),
                    for (final (i, card) in cards.indexed)
                      Padding(
                        padding: EdgeInsets.only(bottom: theme.spacing.sm),
                        child: _CardPreviewTile(index: i + 1, card: card),
                      ),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.knowCount, required this.totalCards});

  final int knowCount;
  final int totalCards;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final fraction = totalCards == 0 ? 0.0 : knowCount / totalCards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Прогресс сегодня', style: theme.typography.textTheme.labelMedium),
            Text(
              '$knowCount / $totalCards',
              style: theme.typography.textTheme.labelMedium
                  ?.copyWith(color: theme.colors.primary),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(theme.radius.pill),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: theme.colors.border,
            valueColor: AlwaysStoppedAnimation(theme.colors.primary),
          ),
        ),
        SizedBox(height: theme.spacing.md),
      ],
    );
  }
}

class _CardPreviewTile extends StatelessWidget {
  const _CardPreviewTile({required this.index, required this.card});

  final int index;
  final dynamic card;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final front = card.front as Map<String, dynamic>;
    final text = front['text'] as String? ?? 'Карточка $index';
    return AscendGlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.md,
        vertical: theme.spacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(theme.radius.sm),
            ),
            child: Text(
              '$index',
              style: theme.typography.textTheme.labelSmall
                  ?.copyWith(color: theme.colors.primary),
            ),
          ),
          SizedBox(width: theme.spacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.typography.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
