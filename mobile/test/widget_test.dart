import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/app.dart';

void main() {
  testWidgets('Ascend app renders home with hotbar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AscendApp()));
    await tester.pumpAndSettle();

    expect(find.text('Доброе утро, Андрей'), findsOneWidget);
    expect(find.text('Начать обучение'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
  });
}
