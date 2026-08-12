import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../data/models/course_models.dart';
import '../../learn/application/courses_provider.dart';

class KnowledgeScreen extends ConsumerWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    final coursesAsync = ref.watch(coursesProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ignore: prefer_const_constructors
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.lg,
              theme.spacing.lg,
              theme.spacing.lg,
              theme.spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('База знаний', style: text.headlineMedium),
                SizedBox(height: theme.spacing.xxs),
                Text(
                  'Конспекты по темам курса',
                  style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                ),
              ],
            ),
          ),
        ),
        coursesAsync.when(
          loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
          error: (_, __) => SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Text('Не удалось загрузить курсы.', style: text.bodyLarge?.copyWith(color: theme.colors.error)),
            ),
          ),
          data: (snapshot) {
            final unlocked = snapshot.courses.where((c) => !c.locked).toList();
            if (unlocked.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing.lg),
                  child: Text('Нет доступных курсов.', style: text.bodyLarge?.copyWith(color: theme.colors.muted)),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                0,
                theme.spacing.lg,
                theme.spacing.hotbarContentInset,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = unlocked[index];
                    return _CourseKnowledgeCard(course: course);
                  },
                  childCount: unlocked.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CourseKnowledgeCard extends ConsumerStatefulWidget {
  const _CourseKnowledgeCard({required this.course});

  final CourseSummary course;

  @override
  ConsumerState<_CourseKnowledgeCard> createState() => _CourseKnowledgeCardState();
}

class _CourseKnowledgeCardState extends ConsumerState<_CourseKnowledgeCard> {
  bool _loading = false;
  List<({TopicSummary topic, List<SourceDocument> docs})> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final detail = await ref.read(courseDetailProvider(widget.course.id).future);
      if (detail == null) return;
      final api = ref.read(apiClientProvider);
      final items = <({TopicSummary topic, List<SourceDocument> docs})>[];
      for (final section in detail.sections) {
        for (final topic in section.topics) {
          if (topic.locked) continue;
          try {
            final docs = await api.fetchTopicDocuments(topic.id);
            if (docs.isNotEmpty) {
              items.add((topic: topic, docs: docs));
            }
          } catch (_) {}
        }
      }
      if (mounted) setState(() => _items = items);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDoc(SourceDocument doc, {String? highlight}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final theme = context.ascendTheme;
        final text = theme.typography.textTheme;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          builder: (context, controller) => Padding(
            padding: EdgeInsets.all(theme.spacing.lg),
            child: ListView(
              controller: controller,
              children: [
                Text(doc.title, style: text.titleLarge),
                SizedBox(height: theme.spacing.md),
                for (final block in doc.blocks)
                  Container(
                    margin: EdgeInsets.only(bottom: theme.spacing.sm),
                    padding: EdgeInsets.all(theme.spacing.sm),
                    decoration: BoxDecoration(
                      color: highlight != null && block.id == highlight
                          ? theme.colors.primary.withValues(alpha: 0.12)
                          : null,
                      borderRadius: BorderRadius.circular(theme.radius.md),
                    ),
                    child: Text(
                      block.payload['text']?.toString() ?? '',
                      style: block.type == 'heading' ? text.titleMedium : text.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.md),
      child: AscendGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title, style: text.titleLarge),
            SizedBox(height: theme.spacing.sm),
            if (_loading) const LinearProgressIndicator(),
            if (!_loading && _items.isEmpty)
              Text('Конспекты пока не опубликованы.', style: text.bodyMedium?.copyWith(color: theme.colors.muted)),
            for (final item in _items) ...[
              Text(item.topic.title, style: text.titleSmall),
              SizedBox(height: theme.spacing.xxs),
              for (final doc in item.docs)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(Icons.description_outlined, color: theme.colors.primary),
                  title: Text(doc.title),
                  onTap: () => _openDoc(doc),
                ),
              SizedBox(height: theme.spacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
