import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/knowledge/presentation/ai_interview_screen.dart';
import '../../features/knowledge/presentation/knowledge_screen.dart';
import '../../features/learn/presentation/card_player_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/learn/presentation/topic_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/shell/presentation/ascend_shell.dart';
import '../../data/models/course_models.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterRefresh extends ChangeNotifier {
  RouterRefresh(this._ref) {
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return refresh;
});

bool _isAuthRoute(String location) {
  return location == '/welcome' || location == '/login' || location == '/register';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.status == AuthStatus.loading) {
        return null;
      }

      if (auth.canUseApp) {
        if (_isAuthRoute(location)) {
          return '/home';
        }
        return null;
      }

      if (!_isAuthRoute(location)) {
        return '/welcome';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => const NoTransitionPage(child: WelcomeScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => const NoTransitionPage(child: RegisterScreen()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AscendShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (context, state) => const NoTransitionPage(child: LearnScreen()),
            routes: [
              GoRoute(
                path: 'topic/:topicId',
                builder: (context, state) {
                  final topic = state.extra as TopicSummary?;
                  if (topic == null) {
                    return const _NotFoundWidget();
                  }
                  return TopicScreen(topic: topic);
                },
                routes: [
                  GoRoute(
                    path: 'cards',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      final cards = extra?['cards'] as List<CardPreview>?;
                      final topic = extra?['topic'] as TopicSummary?;
                      if (cards == null || topic == null) {
                        return const _NotFoundWidget();
                      }
                      return CardPlayerEntry(cards: cards, topic: topic);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/knowledge',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: KnowledgeScreen()),
          ),
          GoRoute(
            path: '/ai-interview',
            builder: (context, state) => const AIInterviewScreen(),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

class _NotFoundWidget extends StatelessWidget {
  const _NotFoundWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Страница не найдена')),
    );
  }
}
