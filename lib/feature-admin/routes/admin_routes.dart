import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/admin_platform_config.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';

/// Middleware to validate desktop platform for admin routes
class AdminPlatformGuard extends StatelessWidget {
  final Widget child;

  const AdminPlatformGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    try {
      AdminPlatformConfig.validatePlatform();
      return child;
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// Admin route configuration for GoRouter
final adminRoutes = [
  GoRoute(
    path: '/admin',
    redirect: (context, state) {
      if (state.fullPath == '/admin') {
        return '/admin/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: 'dashboard',
        builder:
            (context, state) =>
                const AdminPlatformGuard(child: AdminDashboardScreen()),
      ),
      // Additional admin routes will be added here
      GoRoute(
        path: 'users',
        builder:
            (context, state) => const AdminPlatformGuard(
              child: Scaffold(
                body: Center(child: Text('User Management - Coming Soon')),
              ),
            ),
      ),
      GoRoute(
        path: 'departments',
        builder:
            (context, state) => const AdminPlatformGuard(
              child: Scaffold(
                body: Center(
                  child: Text('Department Management - Coming Soon'),
                ),
              ),
            ),
      ),
      GoRoute(
        path: 'courses',
        builder:
            (context, state) => const AdminPlatformGuard(
              child: Scaffold(
                body: Center(child: Text('Course Management - Coming Soon')),
              ),
            ),
      ),
      GoRoute(
        path: 'groups',
        builder:
            (context, state) => const AdminPlatformGuard(
              child: Scaffold(
                body: Center(child: Text('Group Management - Coming Soon')),
              ),
            ),
      ),
      GoRoute(
        path: 'reports',
        builder:
            (context, state) => const AdminPlatformGuard(
              child: Scaffold(
                body: Center(child: Text('Reports - Coming Soon')),
              ),
            ),
      ),
    ],
  ),
];

/// Error page for invalid admin routes
class AdminNotFoundScreen extends StatelessWidget {
  const AdminNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The requested admin page does not exist.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/admin/dashboard'),
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
