import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventifi_admin/features/auth/presentation/auth_controller.dart';
import 'package:eventifi_admin/features/auth/presentation/login_screen.dart';
import 'package:eventifi_admin/features/dashboard/presentation/dashboard_shell.dart';
import 'package:eventifi_admin/features/roles/presentation/roles_screen.dart';
import 'package:eventifi_admin/features/users/presentation/users_screen.dart';
import 'package:eventifi_admin/features/events/presentation/events_screen.dart';
import 'package:eventifi_admin/features/vendors/presentation/vendors_screen.dart';

// Private Notifier to handle redirection logic based on auth state
final _authListenable = Provider<ValueNotifier<bool>>((ref) {
  final notifier = ValueNotifier<bool>(false);
  
  // Listen to controller
  ref.listen(authControllerProvider, (_, next) {
    if (next.value != null) {
      notifier.value = true; // Logged In
    } else {
      notifier.value = false; // Logged Out
    }
  });
  
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: ref.watch(_authListenable),
    redirect: (context, state) async {
       // Check storage if state is null (app start)
       final storage = ref.read(storageServiceProvider);
       final token = await storage.getToken();
       final isLoggedIn = token != null || authState.value != null;
       
       final isLoginRoute = state.uri.path == '/login';
       
       if (!isLoggedIn && !isLoginRoute) {
         return '/login';
       }
       
       if (isLoggedIn && isLoginRoute) {
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
        builder: (context, state, child) {
          return DashboardShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Center(child: Text('Dashboard Home')),
          ),
          GoRoute(
            path: '/roles', 
            builder: (context, state) => const RolesScreen(),
          ),
           GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/vendors',
            builder: (context, state) => const VendorsScreen(),
          ),
        ],
      ),
    ],
  );
});
