import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../../feature-teacher/models/session_model.dart';
import '../../feature-teacher/models/attendance_model.dart';

// Student courses provider
final studentCoursesProvider = FutureProvider.autoDispose((ref) async {
  final client = Supabase.instance.client;
  final currentStudent = ref.watch(currentProfileProvider);

  if (currentStudent == null) {
    throw Exception('Student profile not found');
  }

  final response = await client
      .from('student_groups')
      .select('''
        *,
        group_courses (
          *,
          courses (
            id,
            code,
            title,
            credit_hours,
            description
          )
        )
      ''')
      .eq('student_id', currentStudent.id)
      .order('created_at', ascending: false);

  return response;
});

// Student attendance history provider
final studentAttendanceProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, String>((ref, courseId) async {
      final client = Supabase.instance.client;
      final currentStudent = ref.watch(currentProfileProvider);

      if (currentStudent == null) {
        throw Exception('Student profile not found');
      }

      final response = await client
          .from('attendance')
          .select('''
        *,
        sessions!inner (
          id,
          title,
          session_date,
          start_time,
          end_time,
          type_c,
          course_id
        )
      ''')
          .eq('student_id', currentStudent.id)
          .eq('sessions.course_id', courseId)
          .order('created_at', ascending: false);

      return response;
    });

// Attendance statistics provider
final attendanceStatsProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, courseId) async {
      final client = Supabase.instance.client;
      final currentStudent = ref.watch(currentProfileProvider);

      if (currentStudent == null) {
        throw Exception('Student profile not found');
      }

      final response = await client
          .from('attendance')
          .select('''
        status,
        count
      ''')
          .eq('student_id', currentStudent.id)
          .eq('sessions.course_id', courseId)
          .select('*');

      final stats = {
        'total': 0,
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
      };

      for (final record in response as List) {
        stats['total'] = stats['total']! + 1;
        stats[record['status']] = stats[record['status']]! + 1;
      }

      return stats;
    });

// QR Code scanning and attendance marking
final qrScannerProvider =
    StateNotifierProvider<QRScannerNotifier, AsyncValue<void>>((ref) {
      return QRScannerNotifier(ref);
    });

class QRScannerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  QRScannerNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> markAttendance(String qrCode) async {
    state = const AsyncValue.loading();

    try {
      final client = Supabase.instance.client;
      final currentStudent = _ref.read(currentProfileProvider);

      if (currentStudent == null) {
        throw Exception('Student profile not found');
      }

      // First verify the QR code is valid and session exists
      final sessionResponse =
          await client
              .from('sessions')
              .select()
              .eq('qr_code', qrCode)
              .gte('qr_expiry', DateTime.now().toIso8601String())
              .single();

      final sessionId = sessionResponse['id'] as String;

      // Check if attendance is already marked
      final existingAttendance =
          await client
              .from('attendance')
              .select()
              .eq('session_id', sessionId)
              .eq('student_id', currentStudent.id)
              .maybeSingle();

      if (existingAttendance != null) {
        throw Exception('Attendance already marked for this session');
      }

      // Mark attendance
      await client.from('attendance').insert({
        'session_id': sessionId,
        'student_id': currentStudent.id,
        'status': AttendanceStatus.present.toString(),
        'check_in_time': DateTime.now().toIso8601String(),
      });

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Filter providers
final selectedSessionTypeProvider = StateProvider<SessionType?>((ref) => null);

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});
}

final selectedDateRangeProvider = StateProvider<DateRange?>((ref) => null);

// Filtered attendance provider
final filteredAttendanceProvider =
    Provider.family<List<Map<String, dynamic>>, List<Map<String, dynamic>>>((
      ref,
      attendance,
    ) {
      final selectedType = ref.watch(selectedSessionTypeProvider);
      final dateRange = ref.watch(selectedDateRangeProvider);

      return attendance.where((record) {
        final session = record['sessions'] as Map<String, dynamic>;
        final sessionDate = DateTime.parse(session['session_date'] as String);

        bool matchesType = true;
        if (selectedType != null) {
          matchesType = session['type_c'] == selectedType.toString();
        }

        bool matchesDateRange = true;
        if (dateRange != null) {
          matchesDateRange =
              sessionDate.isAfter(dateRange.start) &&
              sessionDate.isBefore(dateRange.end);
        }

        return matchesType && matchesDateRange;
      }).toList();
    });
