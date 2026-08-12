import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_button.dart';
import '../application/auth_controller.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.ascendTheme;
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.status == AuthStatus.loading;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  'Ascend',
                  style: theme.typography.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: theme.spacing.sm),
                Text(
                  'Учись, запоминай, доказывай навыки — и выходи на оффер.',
                  style: theme.typography.textTheme.bodyLarge?.copyWith(
                    color: theme.colors.muted,
                  ),
                ),
                SizedBox(height: theme.spacing.xl),
                AscendGlassButton(
                  label: isLoading ? 'Загрузка…' : 'Войти',
                  icon: Icons.login_rounded,
                  onPressed: isLoading ? null : () => context.push('/login'),
                ),
                SizedBox(height: theme.spacing.sm),
                AscendGlassButton(
                  label: 'Создать аккаунт',
                  icon: Icons.person_add_rounded,
                  onPressed: isLoading ? null : () => context.push('/register'),
                ),
                SizedBox(height: theme.spacing.sm),
                AscendGlassButton(
                  label: 'Демо без аккаунта',
                  icon: Icons.visibility_rounded,
                  expanded: true,
                  onPressed: isLoading
                      ? null
                      : () => ref.read(authControllerProvider.notifier).enterDemoMode(),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}
