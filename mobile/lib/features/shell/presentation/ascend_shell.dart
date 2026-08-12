import 'package:flutter/material.dart';

import '../../../core/widgets/ascend_background.dart';
import 'ascend_hotbar.dart';

class AscendShell extends StatelessWidget {
  const AscendShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AscendBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: child,
        bottomNavigationBar: const AscendHotbar(),
      ),
    );
  }
}
