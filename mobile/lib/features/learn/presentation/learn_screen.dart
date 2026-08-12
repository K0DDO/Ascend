import 'package:flutter/material.dart';

import '../../../shared/widgets/ascend_placeholder_tab.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AscendPlaceholderTab(
      title: 'Обучение',
      subtitle: 'Темы и оптимальные сессии появятся здесь.',
      icon: Icons.school_rounded,
    );
  }
}
