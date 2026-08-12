import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/theme/glass_effect_provider.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../shared/widgets/ascend_placeholder_tab.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final mode = ref.watch(themeModeProvider);
    final glassStrength = ref.watch(glassEffectStrengthProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.lg,
              theme.spacing.lg,
              theme.spacing.lg,
              theme.spacing.md,
            ),
            child: Text('Профиль', style: theme.typography.textTheme.headlineMedium),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тема', style: theme.typography.textTheme.titleMedium),
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
                  ],
                ),
              ),
              SizedBox(height: theme.spacing.md),
              AscendGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Эффект стекла', style: theme.typography.textTheme.titleMedium),
                    SizedBox(height: theme.spacing.sm),
                    Slider(
                      value: glassStrength,
                      onChanged: (value) {
                        ref.read(glassEffectStrengthProvider.notifier).state = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: theme.spacing.lg),
              const AscendPlaceholderTab(
                title: '',
                subtitle: 'Аккаунт, устройства и диагностика появятся позже.',
                icon: Icons.person_rounded,
                compact: true,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
