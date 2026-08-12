import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../data/local/database_provider.dart';
import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../data/models/course_models.dart';
import '../../../data/models/learning_models.dart';

// ---------------------------------------------------------------------------
// Session state
// ---------------------------------------------------------------------------

enum _CardFace { front, back }

class _SessionState {
  _SessionState({
    required this.cards,
    this.index = 0,
    this.face = _CardFace.front,
    this.knowCount = 0,
    this.repeatCount = 0,
    this.done = false,
    this.questionStartedAt,
    this.answerStartedAt,
    this.sourceOpened = false,
  });

  final List<CardPreview> cards;
  final int index;
  final _CardFace face;
  final int knowCount;
  final int repeatCount;
  final bool done;
  final DateTime? questionStartedAt;
  final DateTime? answerStartedAt;
  final bool sourceOpened;

  CardPreview? get currentCard => index < cards.length ? cards[index] : null;
  int get total => cards.length;

  _SessionState copyWith({
    int? index,
    _CardFace? face,
    int? knowCount,
    int? repeatCount,
    bool? done,
    DateTime? questionStartedAt,
    DateTime? answerStartedAt,
    bool? sourceOpened,
    bool clearAnswerStart = false,
  }) =>
      _SessionState(
        cards: cards,
        index: index ?? this.index,
        face: face ?? this.face,
        knowCount: knowCount ?? this.knowCount,
        repeatCount: repeatCount ?? this.repeatCount,
        done: done ?? this.done,
        questionStartedAt: questionStartedAt ?? this.questionStartedAt,
        answerStartedAt: clearAnswerStart ? null : (answerStartedAt ?? this.answerStartedAt),
        sourceOpened: sourceOpened ?? this.sourceOpened,
      );
}

class _SessionNotifier extends StateNotifier<_SessionState> {
  _SessionNotifier(List<CardPreview> cards)
      : super(_SessionState(cards: cards, questionStartedAt: DateTime.now()));

  void flip() {
    if (state.face == _CardFace.back || state.done) return;
    state = state.copyWith(
      face: _CardFace.back,
      answerStartedAt: DateTime.now(),
    );
  }

  /// Returns the signal to record, then advances.
  ReviewSignal? review(String result) {
    final card = state.currentCard;
    if (card == null || state.done) return null;

    final now = DateTime.now();
    final questionMs = state.answerStartedAt != null
        ? state.answerStartedAt!.difference(state.questionStartedAt ?? now).inMilliseconds
        : now.difference(state.questionStartedAt ?? now).inMilliseconds;
    final answerMs = state.answerStartedAt != null
        ? now.difference(state.answerStartedAt!).inMilliseconds
        : 0;

    final signal = ReviewSignal(
      cardId: card.id,
      cardVersionId: card.versionId,
      result: result,
      questionMs: questionMs.clamp(0, 300000),
      answerMs: answerMs.clamp(0, 300000),
      sourceOpened: state.sourceOpened,
    );

    final nextIndex = state.index + 1;
    final isDone = nextIndex >= state.cards.length;

    state = state.copyWith(
      index: nextIndex,
      face: _CardFace.front,
      knowCount: result == 'know' ? state.knowCount + 1 : state.knowCount,
      repeatCount: result == 'repeat' ? state.repeatCount + 1 : state.repeatCount,
      done: isDone,
      questionStartedAt: isDone ? null : DateTime.now(),
      clearAnswerStart: true,
      sourceOpened: false,
    );

    return signal;
  }

  void markSourceOpened() {
    state = state.copyWith(sourceOpened: true);
  }
}

final _sessionProvider =
    StateNotifierProvider.autoDispose<_SessionNotifier, _SessionState>((ref) {
  throw UnimplementedError('override with cards');
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CardPlayerScreen extends ConsumerStatefulWidget {
  const CardPlayerScreen({
    super.key,
    required this.cards,
    required this.topic,
  });

  final List<CardPreview> cards;
  final TopicSummary topic;

  @override
  ConsumerState<CardPlayerScreen> createState() => _CardPlayerScreenState();
}

class _CardPlayerScreenState extends ConsumerState<CardPlayerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _flip() async {
    if (_isFlipping) return;
    final session = ref.read(_sessionProvider.notifier);
    final state = ref.read(_sessionProvider);
    if (state.face == _CardFace.back || state.done) return;
    _isFlipping = true;
    HapticFeedback.lightImpact();
    await _flipController.forward();
    session.flip();
    _isFlipping = false;
  }

  Future<void> _review(String result) async {
    final notifier = ref.read(_sessionProvider.notifier);
    final signal = notifier.review(result);
    HapticFeedback.mediumImpact();

    // Fire-and-forget to backend (offline resilient)
    if (signal != null) {
      unawaited(
        ref.read(apiClientProvider).recordReview(signal).catchError((_) async {
          final store = await ref.read(localContentStoreProvider.future);
          await store.enqueueOutbox(
            eventType: 'learning.review',
            payload: signal.toJson(),
          );
          return ReviewResult.fromJson({'event_id': '', 'card_id': signal.cardId, 'result': signal.result});
        }),
      );
    }

    // Reset flip for next card
    _flipController.reset();
  }

  Future<void> _openSource(CardPreview card) async {
    final refSource = card.sources.first;
    ref.read(_sessionProvider.notifier).markSourceOpened();
    try {
      final doc = await ref.read(apiClientProvider).fetchDocument(refSource.documentId);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => _SourceSheet(document: doc, highlightBlockId: refSource.blockId),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть конспект')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(_sessionProvider);
    final theme = context.ascendTheme;

    if (session.done) {
      return _SessionSummary(
        topic: widget.topic,
        knowCount: session.knowCount,
        repeatCount: session.repeatCount,
        total: session.total,
      );
    }

    final card = session.currentCard!;
    final progress = (session.index + 1) / session.total;
    final isBack = session.face == _CardFace.back;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.md,
                vertical: theme.spacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic.title,
                          style: theme.typography.textTheme.labelMedium
                              ?.copyWith(color: theme.colors.muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${session.index + 1} / ${session.total}',
                          style: theme.typography.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(theme.radius.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: theme.colors.border,
                  valueColor: AlwaysStoppedAnimation(theme.colors.primary),
                ),
              ),
            ),
            SizedBox(height: theme.spacing.lg),
            // Flip card
            Expanded(
              child: GestureDetector(
                onTap: isBack ? null : _flip,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, _) {
                      final angle = _flipAnimation.value * math.pi;
                      final showFront = angle < math.pi / 2;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: showFront
                            ? _CardFaceWidget(
                                content: card.front,
                                label: 'Вопрос',
                                hint: 'Нажмите, чтобы увидеть ответ',
                                isPrimary: false,
                              )
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _CardFaceWidget(
                                  content: card.back,
                                  label: 'Ответ',
                                  isPrimary: true,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: theme.spacing.lg),
            // Action buttons
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: isBack
                  ? Padding(
                      key: const ValueKey('buttons'),
                      padding: EdgeInsets.fromLTRB(
                        theme.spacing.lg,
                        0,
                        theme.spacing.lg,
                        theme.spacing.hotbarContentInset + theme.spacing.md,
                      ),
                      child: Column(
                        children: [
                          if (session.currentCard?.sources.isNotEmpty == true) ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _openSource(session.currentCard!),
                                icon: const Icon(Icons.menu_book_rounded),
                                label: const Text('Подробнее'),
                              ),
                            ),
                            SizedBox(height: theme.spacing.sm),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  label: 'Повторить',
                                  icon: Icons.replay_rounded,
                                  color: theme.colors.warning,
                                  onTap: () => _review('repeat'),
                                ),
                              ),
                              SizedBox(width: theme.spacing.md),
                              Expanded(
                                child: _ActionButton(
                                  label: 'Знаю',
                                  icon: Icons.check_rounded,
                                  color: theme.colors.success,
                                  onTap: () => _review('know'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      key: const ValueKey('flip_hint'),
                      padding: EdgeInsets.fromLTRB(
                        theme.spacing.lg,
                        0,
                        theme.spacing.lg,
                        theme.spacing.hotbarContentInset + theme.spacing.md,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _flip,
                          icon: const Icon(Icons.flip_rounded),
                          label: const Text('Перевернуть'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(theme.radius.pill),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFaceWidget extends StatelessWidget {
  const _CardFaceWidget({
    required this.content,
    required this.label,
    this.hint,
    this.isPrimary = false,
  });

  final Map<String, dynamic> content;
  final String label;
  final String? hint;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = content['text'] as String? ?? '';

    return AscendGlassCard(
      strong: isPrimary,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.typography.textTheme.labelSmall?.copyWith(
                color: isPrimary ? theme.colors.primary : theme.colors.muted,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: theme.spacing.md),
            Text(
              text,
              style: theme.typography.textTheme.headlineSmall,
            ),
            if (hint != null) ...[
              SizedBox(height: theme.spacing.lg),
              Text(
                hint!,
                style: theme.typography.textTheme.bodySmall
                    ?.copyWith(color: theme.colors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(theme.radius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: theme.spacing.md,
            horizontal: theme.spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: theme.spacing.xs),
              Text(
                label,
                style: theme.typography.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Session summary
// ---------------------------------------------------------------------------

class _SessionSummary extends StatelessWidget {
  const _SessionSummary({
    required this.topic,
    required this.knowCount,
    required this.repeatCount,
    required this.total,
  });

  final TopicSummary topic;
  final int knowCount;
  final int repeatCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final pct = total == 0 ? 0 : (knowCount * 100 / total).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                pct >= 80
                    ? Icons.emoji_events_rounded
                    : pct >= 50
                        ? Icons.thumb_up_rounded
                        : Icons.replay_rounded,
                color: pct >= 80
                    ? theme.colors.warning
                    : pct >= 50
                        ? theme.colors.success
                        : theme.colors.muted,
                size: 56,
              ),
              SizedBox(height: theme.spacing.lg),
              Text(
                pct >= 80 ? 'Отлично!' : pct >= 50 ? 'Хороший результат' : 'Продолжайте практику',
                style: theme.typography.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                topic.title,
                style: theme.typography.textTheme.bodyLarge
                    ?.copyWith(color: theme.colors.muted),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: theme.spacing.xl),
              AscendGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCol(
                      value: '$knowCount',
                      label: 'Знаю',
                      color: theme.colors.success,
                    ),
                    _StatCol(
                      value: '$repeatCount',
                      label: 'Повторить',
                      color: theme.colors.warning,
                    ),
                    _StatCol(
                      value: '$pct%',
                      label: 'Результат',
                      color: theme.colors.primary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(theme.radius.pill),
                        ),
                      ),
                      child: const Text('К теме'),
                    ),
                  ),
                  SizedBox(width: theme.spacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // Go back to learn tab
                        context.go('/learn');
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('На главную'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(theme.radius.pill),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    return Column(
      children: [
        Text(value,
            style: theme.typography.textTheme.headlineMedium?.copyWith(color: color)),
        Text(label,
            style: theme.typography.textTheme.labelSmall
                ?.copyWith(color: theme.colors.muted)),
      ],
    );
  }
}

// Entrypoint that overrides the session provider
class CardPlayerEntry extends ConsumerWidget {
  const CardPlayerEntry({
    super.key,
    required this.cards,
    required this.topic,
  });

  final List<CardPreview> cards;
  final TopicSummary topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        _sessionProvider.overrideWith((_) => _SessionNotifier(cards)),
      ],
      child: CardPlayerScreen(cards: cards, topic: topic),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet({required this.document, this.highlightBlockId});

  final SourceDocument document;
  final String? highlightBlockId;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: EdgeInsets.fromLTRB(theme.spacing.lg, theme.spacing.md, theme.spacing.lg, theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(document.title, style: text.titleLarge),
              SizedBox(height: theme.spacing.sm),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: document.blocks.length,
                  itemBuilder: (context, index) {
                    final block = document.blocks[index];
                    final highlighted = highlightBlockId != null && block.id == highlightBlockId;
                    final body = block.payload['text']?.toString() ?? '';
                    return Container(
                      margin: EdgeInsets.only(bottom: theme.spacing.sm),
                      padding: EdgeInsets.all(theme.spacing.sm),
                      decoration: BoxDecoration(
                        color: highlighted
                            ? theme.colors.primary.withValues(alpha: 0.12)
                            : theme.colors.surface.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(theme.radius.md),
                        border: highlighted
                            ? Border.all(color: theme.colors.primary.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: Text(
                        body,
                        style: (block.type == 'heading' ? text.titleMedium : text.bodyMedium)
                            ?.copyWith(fontWeight: highlighted ? FontWeight.w600 : null),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
