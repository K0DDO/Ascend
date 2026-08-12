import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ascend/app.dart';
import 'package:ascend/features/auth/application/auth_controller.dart';
import 'package:ascend/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('Ascend app renders home with hotbar in guest mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) {
            return AuthController(
              ref.watch(authRepositoryProvider),
              autoBootstrap: false,
            )..state = const AuthState.guest();
          }),
        ],
        child: const AscendApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Доброе утро, Андрей'), findsOneWidget);
    expect(find.text('Начать обучение'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
  });
}
