import 'package:flutter/material.dart';

import '../../../shared/widgets/ascend_placeholder_tab.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AscendPlaceholderTab(
      title: 'Прогресс',
      subtitle: 'Mastery, retention и готовность появятся здесь.',
      icon: Icons.insights_rounded,
    );
  }
}
