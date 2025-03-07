import 'package:qr_code_attendnce_2/core/models/user_profile.dart';
import 'package:qr_code_attendnce_2/feature-teacher/models/session_model.dart';

class TestData {
  // Auth Test Data
  static const validEmail = 'test@example.com';
  static const validPassword = 'password123';
  static const invalidEmail = 'invalid-email';
  static const shortPassword = '12345';
  static const mockErrorMessage = 'Mock error message';

  // Test User Profiles
  static final testStudentProfile = UserProfile(
    id: 'test-student-id',
    firstName: 'John',
    lastName: 'Student',
    role: UserRole.student,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final testTeacherProfile = UserProfile(
    id: 'test-teacher-id',
    firstName: 'Jane',
    lastName: 'Teacher',
    role: UserRole.teacher,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static final testAdminProfile = UserProfile(
    id: 'test-admin-id',
    firstName: 'Admin',
    lastName: 'User',
    role: UserRole.admin,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // Dev Account Test Data
  static const devSignupData = {
    'email': 'dev@example.com',
    'password': 'devpass123',
    'firstName': 'Dev',
    'lastName': 'User',
    'role': UserRole.student,
  };

  // Course Test Data
  static final mockCourse = {
    'id': 'test-course-id',
    'code': 'CS101',
    'title': 'Introduction to Programming',
    'credit_hours': 3,
    'description': 'An introductory course to programming concepts',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  // Session Test Data
  static final mockSession = {
    'id': 'test-session-id',
    'title': 'Test Session',
    'course_id': mockCourse['id'],
    'teacher_id': testTeacherProfile.id,
    'group_id': 'test-group-id',
    'session_date': DateTime.now().toIso8601String(),
    'start_time': '09:00',
    'end_time': '10:30',
    'room': 'A101',
    'type_c': SessionType.course.name,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  // QR Code Test Data
  static const validQrCode = 'valid-qr-code-123';
  static const expiredQrCode = 'expired-qr-code-456';
  static const invalidQrCode = 'invalid-qr-code-789';

  // Auth Error Messages
  static const invalidCredentials = 'Invalid email or password';
  static const emailInUse = 'Email already in use';
  static const weakPassword = 'Password is too weak';
  static const invalidEmailFormat = 'Invalid email format';
  static const networkError = 'Network error occurred';
  static const serverError = 'Server error occurred';

  // QR Code Error Messages
  static const invalidQrCodeError = 'Invalid QR code';
  static const expiredQrCodeError = 'QR code has expired';
  static const alreadyMarkedError =
      'Attendance already marked for this session';
  static const sessionNotFoundError = 'Session not found';

  // Auth States
  static const loadingMessage = 'Authenticating...';
  static const successMessage = 'Successfully authenticated';
  static const logoutMessage = 'Successfully logged out';
  static const sessionExpiredMessage = 'Session expired, please login again';

  // Navigation Routes
  static const loginRoute = '/login';
  static const devSignupRoute = '/dev-signup';
  static const studentDashboardRoute = '/student';
  static const teacherDashboardRoute = '/teacher';
  static const adminDashboardRoute = '/admin';

  // Attendance Status Messages
  static const markingAttendance = 'Marking attendance...';
  static const attendanceMarked = 'Attendance marked successfully';
  static const attendanceError = 'Failed to mark attendance';
}
