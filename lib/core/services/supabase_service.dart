import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../../feature-teacher/models/session_model.dart';
import '../../feature-teacher/models/attendance_model.dart';
import 'logger_service.dart';

class SupabaseService {
  final _logger = LoggerService();
  final _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Authentication failed';
      }

      // Get user profile from database
      final userData =
          await _supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();

      return UserProfile.fromJson(userData);
    } catch (e) {
      throw 'Login failed: ${e.toString()}';
    }
  }

  // Sign up with email and password
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    AuthResponse? authResponse;
    _logger.info('Starting signup process', {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
    });

    try {
      // Create auth user
      _logger.info('Creating auth user account');
      authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        _logger.error('Auth user creation failed - null user returned');
        throw 'Failed to create account';
      }

      _logger.info('Auth user created successfully', {
        'userId': authResponse.user!.id,
      });

      // Create user profile in database
      _logger.info('Creating user profile in database', {
        'userId': authResponse.user!.id,
      });

      final userData =
          await _supabase
              .from('profiles')
              .insert({
                'id': authResponse.user!.id,
                'first_name': firstName,
                'last_name': lastName,
                'role':
                    role.name
                        .toLowerCase(), // Database expects lowercase role values
              })
              .select()
              .single();

      _logger.info('User profile created successfully', {
        'userId': authResponse.user!.id,
        'profileId': userData['id'],
      });

      return UserProfile.fromJson(userData);
    } catch (e, stackTrace) {
      _logger.error('Signup process failed', {
        'error': e.toString(),
        'userId': authResponse?.user?.id,
        'stage': authResponse == null ? 'auth_creation' : 'profile_creation',
      }, stackTrace);

      // If something fails, cleanup the auth user if it was created
      if (authResponse?.user != null) {
        _logger.info('Attempting to cleanup auth user', {
          'userId': authResponse!.user!.id,
        });

        try {
          await _supabase.auth.admin.deleteUser(authResponse!.user!.id);
          _logger.info('Auth user cleanup successful', {
            'userId': authResponse!.user!.id,
          });
        } catch (cleanupError, cleanupStackTrace) {
          _logger.error('Failed to cleanup auth user', {
            'userId': authResponse!.user!.id,
            'error': cleanupError.toString(),
          }, cleanupStackTrace);
        }
      }

      throw 'Signup failed: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw 'Logout failed: ${e.toString()}';
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final userData =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      return UserProfile.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<UserProfile> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final userData =
          await _supabase
              .from('profiles')
              .update(updates)
              .eq('id', userId)
              .select()
              .single();

      return UserProfile.fromJson(userData);
    } catch (e) {
      throw 'Profile update failed: ${e.toString()}';
    }
  }

  // Create a new session
  Future<SessionModel> createSession({
    required String title,
    required String courseId,
    required String teacherId,
    required String groupId,
    required DateTime sessionDate,
    required String startTime,
    required String endTime,
    required String room,
    required SessionType type,
  }) async {
    try {
      final sessionData =
          await _supabase
              .from('sessions')
              .insert({
                'title': title,
                'course_id': courseId,
                'teacher_id': teacherId,
                'group_id': groupId,
                'session_date': sessionDate.toIso8601String(),
                'start_time': startTime,
                'end_time': endTime,
                'room': room,
                'type_c': type.name,
              })
              .select()
              .single();

      return SessionModel.fromJson(sessionData);
    } catch (e) {
      throw 'Failed to create session: ${e.toString()}';
    }
  }

  // Update session QR code
  Future<void> updateSessionQRCode({
    required String sessionId,
    required String qrCode,
    required DateTime expiry,
  }) async {
    try {
      await _supabase
          .from('sessions')
          .update({'qr_code': qrCode, 'qr_expiry': expiry.toIso8601String()})
          .eq('id', sessionId);
    } catch (e) {
      throw 'Failed to update QR code: ${e.toString()}';
    }
  }

  // Mark attendance
  Future<void> markAttendance({
    required String sessionId,
    required String studentId,
    required AttendanceStatus status,
    String? notes,
  }) async {
    try {
      await _supabase.from('attendance').insert({
        'session_id': sessionId,
        'student_id': studentId,
        'status': status.name,
        'check_in_time': DateTime.now().toIso8601String(),
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      throw 'Failed to mark attendance: ${e.toString()}';
    }
  }

  // Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Current session
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  String? get currentUserId => _supabase.auth.currentUser?.id;
}
