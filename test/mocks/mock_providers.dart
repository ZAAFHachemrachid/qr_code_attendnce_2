import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_code_attendnce_2/core/providers/auth_provider.dart';
import 'package:qr_code_attendnce_2/core/models/user_profile.dart';

// Mock Auth State Notifier
class MockAuthNotifier extends StateNotifier<AuthState>
    with Mock
    implements AuthStateNotifier {
  MockAuthNotifier() : super(UnauthenticatedState());
}

// Mock Container for Tests
final testContainer = ProviderContainer();

// Default Test User Profile
final testUserProfile = UserProfile(
  id: 'test-id',
  firstName: 'Test',
  lastName: 'User',
  role: UserRole.student,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Provider Overrides
List<Override> getTestOverrides({
  AuthStateNotifier? authNotifier,
  UserRole? userRole,
  UserProfile? userProfile,
}) {
  final mockAuthNotifier = authNotifier ?? MockAuthNotifier();

  return [
    authStateProvider.overrideWithProvider(
      StateNotifierProvider<AuthStateNotifier, AuthState>(
        (ref) => mockAuthNotifier,
      ),
    ),
    userRoleProvider.overrideWithValue(userRole ?? UserRole.student),
    currentProfileProvider.overrideWithValue(userProfile ?? testUserProfile),
  ];
}

// Extension to help with testing providers
extension ProviderContainerX on ProviderContainer {
  void setAuthState(AuthState state) {
    final notifier = read(authStateProvider.notifier) as MockAuthNotifier;
    notifier.state = state;
  }

  void mockSignIn({bool success = true, String? errorMessage}) {
    final notifier = read(authStateProvider.notifier) as MockAuthNotifier;
    if (success) {
      when(() => notifier.signIn(any(), any())).thenAnswer((_) async {
        notifier.state = AuthenticatedState(testUserProfile);
        return;
      });
    } else {
      when(
        () => notifier.signIn(any(), any()),
      ).thenThrow(Exception(errorMessage ?? 'Mock error'));
    }
  }

  void mockSignUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    bool success = true,
    String? errorMessage,
  }) {
    final notifier = read(authStateProvider.notifier) as MockAuthNotifier;
    if (success) {
      when(
        () => notifier.signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          role: role,
        ),
      ).thenAnswer((_) async {
        notifier.state = AuthenticatedState(testUserProfile);
        return;
      });
    } else {
      when(
        () => notifier.signUp(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          role: role,
        ),
      ).thenThrow(Exception(errorMessage ?? 'Mock error'));
    }
  }
}
