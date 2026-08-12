import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_button.dart';
import '../application/auth_controller.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.status == AuthStatus.loading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isSignedIn && context.mounted) {
        context.go('/home');
      }
    });

    return AuthScaffold(
      title: 'Вход',
      subtitle: 'Продолжай с того места, где остановился',
      footer: TextButton(
        onPressed: () => context.push('/register'),
        child: const Text('Нет аккаунта? Зарегистрироваться'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Введите email';
                if (!value.contains('@')) return 'Некорректный email';
                return null;
              },
            ),
            SizedBox(height: theme.spacing.md),
            AuthTextField(
              label: 'Пароль',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Введите пароль';
                return null;
              },
            ),
            if (auth.errorMessage case final message?) ...[
              SizedBox(height: theme.spacing.md),
              Text(
                message,
                style: theme.typography.textTheme.bodySmall?.copyWith(
                  color: theme.colors.error,
                ),
              ),
            ],
            SizedBox(height: theme.spacing.lg),
            AscendGlassButton(
              label: isLoading ? 'Вход…' : 'Войти',
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
