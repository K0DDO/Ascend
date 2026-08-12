import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/ascend_theme.dart';
import 'core/theme/glass_effect_provider.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/widgets/ascend_background.dart';

class AscendApp extends ConsumerWidget {
  const AscendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final glassStrength = ref.watch(glassEffectStrengthProvider);
    final router = ref.watch(appRouterProvider);
    final lightTheme = AscendTheme.light().toThemeData();
    final darkTheme = AscendTheme.dark().toThemeData();

    return AscendGlassEffectScope(
      strength: glassStrength,
      child: MaterialApp.router(
        title: 'Ascend',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        scrollBehavior: const AscendScrollBehavior(),
        routerConfig: router,
      ),
    );
  }
}
