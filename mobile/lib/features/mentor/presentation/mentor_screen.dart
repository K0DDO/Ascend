import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_card.dart';

class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key});

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _assignments = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(apiClientProvider).fetchMyAssignments();
      if (mounted) setState(() => _assignments = items);
    } catch (_) {
      if (mounted) setState(() => _error = 'Не удалось загрузить задания ментора.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ментор'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                theme.spacing.md,
                theme.spacing.lg,
                theme.spacing.hotbarContentInset,
              ),
              children: [
                Text('Задания', style: text.titleLarge),
                SizedBox(height: theme.spacing.sm),
                if (_error case final err?)
                  Text(err, style: text.bodyMedium?.copyWith(color: theme.colors.error)),
                if (_assignments.isEmpty && _error == null)
                  Text('Пока нет заданий от ментора.', style: text.bodyMedium),
                for (final item in _assignments)
                  Padding(
                    padding: EdgeInsets.only(bottom: theme.spacing.sm),
                    child: AscendGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String? ?? 'Задание', style: text.titleMedium),
                          if (item['note'] case final note? when note.toString().isNotEmpty) ...[
                            SizedBox(height: theme.spacing.xxs),
                            Text(note.toString(), style: text.bodySmall),
                          ],
                          SizedBox(height: theme.spacing.xxs),
                          Text(
                            'Статус: ${item['status'] ?? 'open'}',
                            style: text.labelMedium?.copyWith(color: theme.colors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
