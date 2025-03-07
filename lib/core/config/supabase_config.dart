import 'env_config.dart';

class SupabaseConfig {
  static String get apiUrl => EnvConfig.supabaseUrl;
  static String get anonKey => EnvConfig.supabaseAnonKey;

  // Supabase table names
  static const String profilesTable = 'profiles';
  static const String adminProfilesTable = 'admin_profiles';
  static const String teacherProfilesTable = 'teacher_profiles';
  static const String studentProfilesTable = 'student_profiles';
  static const String departmentsTable = 'departments';
  static const String coursesTable = 'courses';
  static const String sessionsTable = 'sessions';
  static const String attendanceTable = 'attendance';
  static const String studentGroupsTable = 'student_groups';
  static const String groupCoursesTable = 'group_courses';
  static const String teacherCourseGroupsTable = 'teacher_course_groups';

  // Supabase Storage buckets
  static const String profileImagesBucket = 'profile-images';
  static const String qrCodesBucket = 'qr-codes';

  // RLS Policies
  static const teacherRolePolicy = 'teacher';
  static const studentRolePolicy = 'student';
  static const adminRolePolicy = 'admin';

  // Realtime channels
  static String attendanceChannel(String sessionId) => 'attendance:$sessionId';
  static String sessionQrChannel(String sessionId) => 'session-qr:$sessionId';
}
