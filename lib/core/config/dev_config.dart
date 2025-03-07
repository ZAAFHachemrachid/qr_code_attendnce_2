import '../models/user_profile.dart';

/// Test data for development environment
class DevConfig {
  static const testTeacher = {
    'email': 'teacher@test.com',
    'password': 'teacher123',
    'firstName': 'Test',
    'lastName': 'Teacher',
    'role': 'teacher',
  };

  static const testStudent = {
    'email': 'student@test.com',
    'password': 'student123',
    'firstName': 'Test',
    'lastName': 'Student',
    'role': 'student',
  };

  static const testAdmin = {
    'email': 'admin@test.com',
    'password': 'admin123',
    'firstName': 'Test',
    'lastName': 'Admin',
    'role': 'admin',
  };

  static const testCourse = {
    'code': 'CS101',
    'title': 'Introduction to Computer Science',
    'description': 'An introductory course to computer science principles',
    'creditHours': 3,
    'yearOfStudy': 1,
    'semester': 'fall',
  };

  static const testGroup = {
    'academicYear': 2024,
    'currentYear': 1,
    'section': 'A',
    'name': 'CS-2024-1A',
  };

  static const testDepartment = {'name': 'Computer Science', 'code': 'CS'};

  // Pre-filled form data for testing
  static Map<String, String> getTestCredentials(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return {
          'email': testTeacher['email']!,
          'password': testTeacher['password']!,
        };
      case UserRole.student:
        return {
          'email': testStudent['email']!,
          'password': testStudent['password']!,
        };
      case UserRole.admin:
        return {
          'email': testAdmin['email']!,
          'password': testAdmin['password']!,
        };
    }
  }
}
