import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/config/env_config.dart';
import 'core/services/logger_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/screens/login_screen.dart';
import 'core/screens/dev_signup_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/models/user_profile.dart';
import 'feature-student/screens/student_dashboard_screen.dart';
import 'feature-teacher/screens/teacher_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env config
  await EnvConfig.load();

  // Initialize Logger
  await LoggerService().initialize();

  // Initialize Supabase
  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // Initialize app config
  AppConfig().initialize(
    environment: Environment.development, // Change this for production
  );

  runApp(const ProviderScope(child: MyApp()));
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Dev signup route - only accessible in development
      GoRoute(
        path: '/dev-signup',
        builder: (context, state) {
          if (!AppConfig().enableDevSignup) {
            return const LoginScreen();
          }
          return const DevSignupScreen();
        },
      ),
      // Student routes
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      // Teacher routes
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/dev-signup';

      // Allow dev signup in development mode
      if (isSigningUp && AppConfig().enableDevSignup) {
        return null;
      }

      // Check authentication state
      if (authState is AuthenticatedState) {
        if (isLoggingIn || isSigningUp) {
          final userRole = ref.read(userRoleProvider);
          switch (userRole) {
            case UserRole.student:
              return '/student';
            case UserRole.teacher:
              return '/teacher';
            default:
              return '/login';
          }
        }
        return null;
      } else if (authState is UnauthenticatedState) {
        return isLoggingIn || isSigningUp ? null : '/login';
      } else {
        // Loading state
        return null;
      }
    },
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'QR Code Attendance',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
