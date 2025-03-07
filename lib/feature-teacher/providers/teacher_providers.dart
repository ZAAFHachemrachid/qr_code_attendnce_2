import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';

// Sessions provider
final teacherSessionsProvider = FutureProvider.autoDispose<List<SessionModel>>((
  ref,
) async {
  final supabase = SupabaseService();
  final userId = supabase.currentUserId;
  if (userId == null) throw Exception('Not authenticated');

  final response = await Supabase.instance.client
      .from('sessions')
      .select('*, courses(*), groups(*)')
      .eq('teacher_id', userId);

  return (response as List).map((json) => SessionModel.fromJson(json)).toList();
});

// Active sessions provider (sessions happening now)
final activeSessionsProvider = Provider<List<SessionModel>>((ref) {
  final sessionsAsync = ref.watch(teacherSessionsProvider);
  return sessionsAsync.when(
    data: (sessions) {
      final now = DateTime.now();
      return sessions.where((s) {
        final sessionDate = s.sessionDate;
        final startTime = _parseTimeString(s.startTime);
        final endTime = _parseTimeString(s.endTime);
        final currentTime = TimeOfDay.fromDateTime(now);

        return sessionDate.year == now.year &&
            sessionDate.month == now.month &&
            sessionDate.day == now.day &&
            _isTimeInRange(currentTime, startTime, endTime);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

TimeOfDay _parseTimeString(String time) {
  final parts = time.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
  return _timeOfDayToMinutes(current) >= _timeOfDayToMinutes(start) &&
      _timeOfDayToMinutes(current) <= _timeOfDayToMinutes(end);
}

int _timeOfDayToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

// Session QR code management
class QRSessionNotifier extends StateNotifier<AsyncValue<String?>> {
  final SupabaseService _supabase;
  final String _sessionId;

  QRSessionNotifier(this._supabase, this._sessionId)
    : super(const AsyncValue.data(null));

  Future<void> generateQRCode() async {
    state = const AsyncValue.loading();
    try {
      final qrCode = const Uuid().v4();
      final expiry = DateTime.now().add(const Duration(minutes: 5));

      await _supabase.updateSessionQRCode(
        sessionId: _sessionId,
        qrCode: qrCode,
        expiry: expiry,
      );

      state = AsyncValue.data(qrCode);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> invalidateQRCode() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.updateSessionQRCode(
        sessionId: _sessionId,
        qrCode: '',
        expiry: DateTime.now(),
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final qrSessionProvider = StateNotifierProvider.family<
  QRSessionNotifier,
  AsyncValue<String?>,
  String
>((ref, sessionId) => QRSessionNotifier(SupabaseService(), sessionId));

// Attendance management
class AttendanceNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final SupabaseService _supabase;
  final String _sessionId;

  AttendanceNotifier(this._supabase, this._sessionId)
    : super(const AsyncValue.data([])) {
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    state = const AsyncValue.loading();
    try {
      final response = await Supabase.instance.client
          .from('attendance')
          .select('*, student:users(*)')
          .eq('session_id', _sessionId);
      state = AsyncValue.data(response);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAttendance(
    String studentId,
    AttendanceStatus status, {
    String? notes,
  }) async {
    try {
      await _supabase.markAttendance(
        sessionId: _sessionId,
        studentId: studentId,
        status: status,
        notes: notes,
      );
      await fetchAttendance();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final attendanceProvider = StateNotifierProvider.family<
  AttendanceNotifier,
  AsyncValue<List<Map<String, dynamic>>>,
  String
>((ref, sessionId) => AttendanceNotifier(SupabaseService(), sessionId));

// Teacher courses provider
final teacherCoursesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final supabase = SupabaseService();
      final userId = supabase.currentUserId;
      if (userId == null) throw Exception('Not authenticated');

      final response = await Supabase.instance.client
          .from('teacher_courses')
          .select('*, courses(*), groups(*)')
          .eq('teacher_id', userId);

      return response;
    });
