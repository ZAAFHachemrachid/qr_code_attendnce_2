import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_attendnce_2/core/screens/login_screen.dart';
import '../test_config.dart';
import '../mocks/mock_providers.dart';

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late ProviderContainer container;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    container = ProviderContainer(
      overrides: getTestOverrides(authNotifier: mockAuthNotifier),
    );
    setupTestConfig();
  });

  testWidgets('shows validation errors when form is empty', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tapAndSettle(find.text('Login'));

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('shows error on invalid email format', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'invalid-email');
    await tester.enterText(find.byType(TextField).last, 'password123');

    await tester.tapAndSettle(find.text('Login'));

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('shows error on short password', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, '12345');

    await tester.tapAndSettle(find.text('Login'));

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('calls sign in with correct credentials', (tester) async {
    container.mockSignIn(success: true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    await tester.tapAndSettle(find.text('Login'));

    verify(
      () => mockAuthNotifier.signIn('test@example.com', 'password123'),
    ).called(1);
  });

  testWidgets('shows error message on login failure', (tester) async {
    const errorMessage = 'Invalid credentials';
    container.mockSignIn(success: false, errorMessage: errorMessage);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    await tester.tapAndSettle(find.text('Login'));

    expect(find.text('Login failed: $errorMessage'), findsOneWidget);
  });

  testWidgets('shows dev signup button in development mode', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Create Dev Account'), findsOneWidget);
  });
}
