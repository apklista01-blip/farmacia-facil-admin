import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/pharmacies/pharmacies_screen.dart';
import '../screens/users/users_screen.dart';
import '../screens/orders/orders_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(adminAuthProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';
      if (!authState.isAdmin && !loggingIn) {
        return '/login';
      }
      if (authState.isAdmin && loggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/farmacias', builder: (context, state) => const PharmaciesScreen()),
          GoRoute(path: '/usuarios', builder: (context, state) => const UsersScreen()),
          GoRoute(path: '/pedidos', builder: (context, state) => const OrdersScreen()),
        ],
      ),
    ],
  );
});
