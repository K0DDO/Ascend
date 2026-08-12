import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/models/course_models.dart';
import '../../../data/models/learning_models.dart';

// All cards for a topic — from local store (populated by sync)
final topicCardsProvider = FutureProvider.family<List<CardPreview>, String>((ref, topicId) async {
  final store = await ref.watch(localContentStoreProvider.future);
  return store.readCardsForTopic(topicId);
});

// Topic progress from network
final topicProgressProvider = FutureProvider.family<TopicProgress?, String>((ref, topicId) async {
  try {
    return await ref.watch(apiClientProvider).fetchTopicProgress(topicId);
  } catch (_) {
    return null;
  }
});

// SRS-ordered due queue from server
final dueQueueProvider = FutureProvider.family<DueQueue?, String>((ref, topicId) async {
  try {
    return await ref.watch(apiClientProvider).fetchDueQueue(topicId);
  } catch (_) {
    return null;
  }
});

// Resolves ordered cards for the player:
// if SRS queue available → returns cards in SRS order (due + new);
// otherwise falls back to all cards.
final studyQueueProvider =
    FutureProvider.family<List<CardPreview>, String>((ref, topicId) async {
  final allCards = await ref.watch(topicCardsProvider(topicId).future);
  final queue = await ref.watch(dueQueueProvider(topicId).future);

  if (queue == null || queue.items.isEmpty) return allCards;

  final cardMap = {for (final c in allCards) c.id: c};
  final ordered = queue.items
      .map((item) => cardMap[item.cardId])
      .whereType<CardPreview>()
      .toList();

  // Append cards not covered by queue (safety net)
  final inQueue = {for (final item in queue.items) item.cardId};
  for (final card in allCards) {
    if (!inQueue.contains(card.id)) ordered.add(card);
  }
  return ordered;
});
