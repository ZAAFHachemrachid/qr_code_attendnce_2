import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../layouts/student_layout.dart';
import '../providers/student_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/loading_widget.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(studentCoursesProvider);

    return StudentLayout(
      title: 'My Courses',
      child: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You are not enrolled in any courses yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final groupCourses = courses[index]['group_courses'] as List;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    groupCourses.map((gc) {
                      final course = gc['courses'] as Map<String, dynamic>;
                      return _CourseCard(
                        courseId: course['id'] as String,
                        code: course['code'] as String,
                        title: course['title'] as String,
                        creditHours: course['credit_hours'] as int,
                      );
                    }).toList(),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error:
            (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  final String courseId;
  final String code;
  final String title;
  final int creditHours;

  const _CourseCard({
    required this.courseId,
    required this.code,
    required this.title,
    required this.creditHours,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(attendanceStatsProvider(courseId));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to course details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          code,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$creditHours Credits',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.emeraldPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              statsAsync.when(
                data:
                    (stats) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Present',
                          value: '${stats['present']}',
                          color: Colors.green,
                        ),
                        _StatItem(
                          label: 'Absent',
                          value: '${stats['absent']}',
                          color: Colors.red,
                        ),
                        _StatItem(
                          label: 'Late',
                          value: '${stats['late']}',
                          color: Colors.orange,
                        ),
                        _StatItem(
                          label: 'Total',
                          value: '${stats['total']}',
                          color: AppTheme.emeraldPrimary,
                        ),
                      ],
                    ),
                loading:
                    () => const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                error:
                    (error, stack) =>
                        const Center(child: Text('Could not load statistics')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
