import 'package:flutter/material.dart';

import '../../../shared/widgets/ascend_placeholder_tab.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AscendPlaceholderTab(
      title: 'База знаний',
      subtitle: 'Граф курса и конспекты появятся здесь.',
      icon: Icons.menu_book_rounded,
    );
  }
}
