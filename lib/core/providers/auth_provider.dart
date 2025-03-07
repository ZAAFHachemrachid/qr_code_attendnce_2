import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

final userRoleProvider = Provider<UserRole?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthenticatedState) {
    return authState.profile.role;
  }
  return null;
});

final currentProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is AuthenticatedState) {
    return authState.profile;
  }
  return null;
});

// Auth state provider for navigation
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState is AuthenticatedState;
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _supabaseService = SupabaseService();

  AuthStateNotifier() : super(LoadingState()) {
    // Check if user is already authenticated
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    try {
      final profile = await _supabaseService.getCurrentProfile();
      if (profile != null) {
        state = AuthenticatedState(profile);
      } else {
        state = UnauthenticatedState();
      }
    } catch (e) {
      state = UnauthenticatedState();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = LoadingState();
    try {
      final profile = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      state = AuthenticatedState(profile);
    } catch (e) {
      state = UnauthenticatedState();
      throw e.toString();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    state = LoadingState();
    try {
      final profile = await _supabaseService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      state = AuthenticatedState(profile);
    } catch (e) {
      state = UnauthenticatedState();
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = UnauthenticatedState();
    } catch (e) {
      throw e.toString();
    }
  }
}

abstract class AuthState {
  const AuthState();
}

class AuthenticatedState extends AuthState {
  final UserProfile profile;
  const AuthenticatedState(this.profile);
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class LoadingState extends AuthState {
  const LoadingState();
}
