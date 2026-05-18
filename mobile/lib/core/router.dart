import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/habits/models/habit.dart';
import '../features/habits/screens/habits_screen.dart';
import '../features/habits/screens/habit_detail_screen.dart';
import '../features/habits/screens/create_habit_screen.dart';
import '../features/habits/screens/edit_habit_screen.dart';
import '../features/insights/screens/insights_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/reflection/screens/weekly_reflection_screen.dart';
import '../features/habits/screens/templates_screen.dart';

part 'router.g.dart';

final _publicRoutes = {'/login', '/register'};

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authAsync = ref.read(authProvider);

      // While restoring session from storage, stay on current route.
      if (authAsync.isLoading) return null;

      final isAuthenticated =
          authAsync.valueOrNull?.isAuthenticated ?? false;
      final onPublic = _publicRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !onPublic) return '/login';
      if (isAuthenticated && onPublic) return '/habits';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/habits',
        builder: (context, state) => const HabitsScreen(),
      ),
      GoRoute(
        path: '/habits/new',
        builder: (context, state) => const CreateHabitScreen(),
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/reflection',
        builder: (context, state) => const WeeklyReflectionScreen(),
      ),
      GoRoute(
        path: '/habits/:id',
        builder: (context, state) {
          final habit = state.extra as Habit;
          return HabitDetailScreen(habit: habit);
        },
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TemplatesScreen(),
      ),
      GoRoute(
        path: '/habits/:id/edit',
        builder: (context, state) {
          final habit = state.extra as Habit;
          return EditHabitScreen(habit: habit);
        },
      ),
    ],
  );
}

/// Bridges Riverpod auth state changes into a [Listenable] that GoRouter
/// can watch for redirect re-evaluation.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref; // ignore: unused_field
}
