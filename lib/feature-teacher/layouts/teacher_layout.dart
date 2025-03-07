import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_profile.dart';

class TeacherLayout extends ConsumerWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const TeacherLayout({
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
      DrawerItem(title: 'Dashboard', icon: Icons.dashboard, route: '/teacher'),
      DrawerItem(
        title: 'Sessions',
        icon: Icons.calendar_today,
        route: '/teacher/sessions',
      ),
      DrawerItem(
        title: 'Attendance',
        icon: Icons.fact_check,
        route: '/teacher/attendance',
      ),
      DrawerItem(
        title: 'Courses',
        icon: Icons.school,
        route: '/teacher/courses',
      ),
    ];

    final currentLocation = GoRouterState.of(context).uri.path;
    final selectedIndex = _getSelectedIndex(currentLocation);

    return Scaffold(
      appBar: CustomAppBar(title: title, actions: actions),
      drawer: AppDrawer(
        userName: userProfile?.fullName ?? 'Teacher',
        userRole: UserRole.teacher,
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
      case '/teacher':
        return 0;
      case '/teacher/sessions':
        return 1;
      case '/teacher/attendance':
        return 2;
      case '/teacher/courses':
        return 3;
      default:
        return 0;
    }
  }
}
