import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/providers/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardStats {
  final int totalStudents;
  final int totalTeachers;
  final int activeSessions;
  final double todayAttendancePercentage;
  final List<AdminActivity> recentActivities;

  AdminDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.activeSessions,
    required this.todayAttendancePercentage,
    required this.recentActivities,
  });

  factory AdminDashboardStats.initial() {
    return AdminDashboardStats(
      totalStudents: 0,
      totalTeachers: 0,
      activeSessions: 0,
      todayAttendancePercentage: 0,
      recentActivities: [],
    );
  }
}

class AdminActivity {
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  AdminActivity({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}

class AdminDashboardNotifier extends StateNotifier<AdminDashboardStats> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminDashboardNotifier() : super(AdminDashboardStats.initial());

  Future<void> loadDashboardStats() async {
    try {
      // Get total students
      final studentsQuery = await _supabase
          .from('student_profiles')
          .select('id');
      final totalStudents = studentsQuery.length;

      // Get total teachers
      final teachersQuery = await _supabase
          .from('teacher_profiles')
          .select('id');
      final totalTeachers = teachersQuery.length;

      // Get active sessions for today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sessionsQuery = await _supabase
          .from('sessions')
          .select('id')
          .gte('session_date', today.toIso8601String());
      final activeSessions = sessionsQuery.length;

      // Calculate today's attendance percentage
      final attendanceQuery = await _supabase
          .from('attendance')
          .select('status')
          .gte('created_at', today.toIso8601String());

      final totalAttendance = attendanceQuery.length;
      final presentAttendance =
          attendanceQuery
              .where((record) => record['status'] == 'present')
              .length;

      final attendancePercentage =
          totalAttendance > 0
              ? (presentAttendance / totalAttendance) * 100
              : 0.0;

      // Get recent activities
      final recentActivitiesData = await _supabase
          .from('attendance')
          .select('student_id, status, created_at')
          .order('created_at', ascending: false)
          .limit(10);

      final activities =
          recentActivitiesData
              .map(
                (activity) => AdminActivity(
                  title: 'Attendance Recorded',
                  description: 'Student marked as ${activity['status']}',
                  timestamp: DateTime.parse(activity['created_at']),
                  type: 'attendance',
                ),
              )
              .toList();

      // Update state
      state = AdminDashboardStats(
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        activeSessions: activeSessions,
        todayAttendancePercentage: attendancePercentage,
        recentActivities: activities,
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading dashboard stats: $e\n$stackTrace');
      // You might want to handle the error appropriately here
      rethrow;
    }
  }
}

// Provider
final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardNotifier, AdminDashboardStats>((ref) {
      return AdminDashboardNotifier();
    });
