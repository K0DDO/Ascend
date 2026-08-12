import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/theme/theme_mode_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final mode = ref.watch(themeModeProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.lg,
          theme.spacing.hotbarContentInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: theme.typography.textTheme.headlineMedium),
            SizedBox(height: theme.spacing.md),
            Text('Theme', style: theme.typography.textTheme.titleMedium),
            SizedBox(height: theme.spacing.sm),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {mode},
              onSelectionChanged: (selection) {
                ref.read(themeModeProvider.notifier).state = selection.first;
              },
            ),
            SizedBox(height: theme.spacing.lg),
            Text(
              'Account, devices, and diagnostics will live here.',
              style: theme.typography.textTheme.bodyLarge?.copyWith(color: theme.colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
