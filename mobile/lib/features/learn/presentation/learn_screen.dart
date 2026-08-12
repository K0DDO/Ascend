import 'package:flutter/material.dart';

import '../../../shared/widgets/ascend_placeholder_tab.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AscendPlaceholderTab(
      title: 'Learn',
      subtitle: 'Topics and optimal learning sessions will live here.',
      icon: Icons.school_rounded,
    );
  }
}
