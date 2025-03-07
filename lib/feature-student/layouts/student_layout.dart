import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_profile.dart';

class StudentLayout extends ConsumerWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const StudentLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentProfileProvider);

    final drawerItems = [
      DrawerItem(title: 'Dashboard', icon: Icons.dashboard, route: '/student'),
      DrawerItem(
        title: 'Scan QR',
        icon: Icons.qr_code_scanner,
        route: '/student/scan',
      ),
      DrawerItem(
        title: 'My Courses',
        icon: Icons.school,
        route: '/student/courses',
      ),
      DrawerItem(
        title: 'Attendance History',
        icon: Icons.history,
        route: '/student/attendance',
      ),
    ];

    final selectedIndex = _getSelectedIndex(GoRouterState.of(context).uri.path);

    return Scaffold(
      appBar: CustomAppBar(title: title, actions: actions),
      drawer: AppDrawer(
        userName: userProfile?.fullName ?? 'Student',
        userRole: UserRole.student,
        items: drawerItems,
        selectedIndex: selectedIndex,
        onLogout: () {
          ref.read(authStateProvider.notifier).signOut();
        },
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/student':
        return 0;
      case '/student/scan':
        return 1;
      case '/student/courses':
        return 2;
      case '/student/attendance':
        return 3;
      default:
        return 0;
    }
  }
}
