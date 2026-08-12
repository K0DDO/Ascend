import 'package:flutter/material.dart';

import '../../../shared/widgets/ascend_placeholder_tab.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AscendPlaceholderTab(
      title: 'Progress',
      subtitle: 'Mastery, retention, and readiness will live here.',
      icon: Icons.insights_rounded,
    );
  }
}
