import 'package:flutter/material.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_background.dart';
import 'ascend_hotbar.dart';

class AscendShell extends StatelessWidget {
  const AscendShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;

    return AscendBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: theme.spacing.md,
              right: theme.spacing.md,
              bottom: MediaQuery.paddingOf(context).bottom + theme.spacing.xs,
              child: const AscendHotbar(),
            ),
          ],
        ),
      ),
    );
  }
}
