import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/tasks/detail_screen.dart';
import '../features/tasks/home_screen.dart';
import '../features/tasks/task_form_screen.dart';

/// Routeur unique. La redirection se rejoue à chaque changement d'authentification :
/// non connecté => /login ; connecté => on quitte /login.
final routerProvider = Provider<GoRouter>((ref) {
  final changement = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => changement.value++);
  ref.onDispose(changement.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: changement,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final lieu = state.matchedLocation;

      // Lecture du jeton au démarrage : écran d'attente.
      if (auth.isLoading && !auth.hasValue) {
        return lieu == '/splash' ? null : '/splash';
      }
      final connecte = auth.valueOrNull ?? false;
      if (!connecte) return lieu == '/login' ? null : '/login';
      if (lieu == '/login' || lieu == '/splash') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _Splash()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/tache/:id',
        builder: (_, state) => DetailScreen(
          taskId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
        ),
      ),
      GoRoute(path: '/nouvelle', builder: (_, __) => const TaskFormScreen()),
    ],
  );
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
