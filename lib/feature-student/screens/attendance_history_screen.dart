import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../layouts/student_layout.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/loading_widget.dart';
import '../../feature-teacher/models/session_model.dart';
import '../../feature-teacher/models/attendance_model.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SessionType _selectedType = SessionType.course;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SessionType.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedType = SessionType.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StudentLayout(
      title: 'Attendance History',
      child: Column(
        children: [_buildTabBar(), Expanded(child: _buildAttendanceList())],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.emeraldPrimary,
      child: TabBar(
        controller: _tabController,
        tabs:
            SessionType.values.map((type) {
              return Tab(text: type.display);
            }).toList(),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }

  Widget _buildAttendanceList() {
    // TODO: Replace with actual attendance data provider
    final attendanceAsync = AsyncValue.data(<Map<String, dynamic>>[
      {
        'course': 'Introduction to Programming',
        'code': 'CS101',
        'attendance': [
          {
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'status': AttendanceStatus.present,
            'type': SessionType.course,
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 4)),
            'status': AttendanceStatus.absent,
            'type': SessionType.course,
          },
        ],
      },
      {
        'course': 'Data Structures',
        'code': 'CS102',
        'attendance': [
          {
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'status': AttendanceStatus.present,
            'type': SessionType.tp,
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 3)),
            'status': AttendanceStatus.late,
            'type': SessionType.td,
          },
        ],
      },
    ]);

    return attendanceAsync.when(
      data: (courses) => _buildAttendanceContent(courses),
      loading: () => const LoadingWidget(),
      error:
          (error, stack) => Center(child: Text('Error: ${error.toString()}')),
    );
  }

  Widget _buildAttendanceContent(List<Map<String, dynamic>> courses) {
    final filteredCourses =
        courses.where((course) {
          final attendance = List<Map<String, dynamic>>.from(
            course['attendance'],
          );
          return attendance.any((record) => record['type'] == _selectedType);
        }).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No attendance records found for ${_selectedType.display}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        final attendance =
            List<Map<String, dynamic>>.from(
              course['attendance'],
            ).where((record) => record['type'] == _selectedType).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['course'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  course['code'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Divider(),
                ...attendance.map(
                  (record) => _AttendanceRecord(
                    date: record['date'] as DateTime,
                    status: record['status'] as AttendanceStatus,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceRecord extends StatelessWidget {
  final DateTime date;
  final AttendanceStatus status;

  const _AttendanceRecord({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(), size: 20),
          const SizedBox(width: 12),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.toString().split('.').last.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.medical_services;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }
}
