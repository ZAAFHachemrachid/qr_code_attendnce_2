import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../providers/teacher_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/theme/app_theme.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final activeSessions = ref.watch(activeSessionsProvider);
    final userProfile = ref.watch(currentProfileProvider);

    if (userProfile == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final drawerItems = [
      DrawerItem(icon: Icons.dashboard, title: 'Dashboard', route: '/teacher'),
      DrawerItem(
        icon: Icons.calendar_today,
        title: 'Sessions',
        route: '/teacher/sessions',
      ),
      DrawerItem(icon: Icons.book, title: 'Courses', route: '/teacher/courses'),
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Teacher Dashboard'),
      drawer: AppDrawer(
        userName: '${userProfile.firstName} ${userProfile.lastName}',
        userRole: userProfile.role,
        items: drawerItems,
        selectedIndex: 0,
        onLogout: () async {
          await ref.read(authStateProvider.notifier).signOut();
          if (context.mounted) {
            context.go('/login');
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Sessions Section
            Text(
              'Active Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildActiveSessions(activeSessions),
            const SizedBox(height: 32),

            // Courses Section
            Text('My Courses', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildCoursesList(coursesAsync),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/teacher/sessions/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveSessions(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No active sessions'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _ActiveSessionCard(session: session);
      },
    );
  }

  Widget _buildCoursesList(
    AsyncValue<List<Map<String, dynamic>>> coursesAsync,
  ) {
    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No courses assigned'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _CourseCard(course: course);
          },
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  final SessionModel session;
  final dateFormat = DateFormat('HH:mm');

  _ActiveSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/teacher/sessions/${session.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ONGOING',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.emeraldPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${session.startTime} - ${session.endTime}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Room: ${session.room}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/teacher/courses/${course['courses']['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['courses']['title'] as String,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Code: ${course['courses']['code']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (course['groups'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Group: ${course['groups']['name']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
