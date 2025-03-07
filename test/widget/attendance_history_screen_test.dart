import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_code_attendnce_2/feature-student/screens/attendance_history_screen.dart';
import 'package:qr_code_attendnce_2/feature-student/providers/student_providers.dart';
import 'package:qr_code_attendnce_2/feature-teacher/models/session_model.dart';
import '../test_helpers/test_data.dart';
import '../test_config.dart';
import '../mocks/mock_providers.dart';

// Mock attendance notifier
class MockAttendanceNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>>
    with Mock {
  MockAttendanceNotifier() : super(const AsyncValue.data([]));
}

void main() {
  late ProviderContainer container;
  late MockAttendanceNotifier mockAttendanceNotifier;

  setUp(() {
    mockAttendanceNotifier = MockAttendanceNotifier();
    container = ProviderContainer(
      overrides: [
        ...getTestOverrides(),
        studentAttendanceProvider.overrideWithProvider(
          FutureProvider.autoDispose.family((ref, String courseId) async {
            final state = mockAttendanceNotifier.state;
            return state.when(
              data: (data) => data,
              loading: () => throw const AsyncLoading(),
              error: (error, stack) => throw error,
            );
          }),
        ),
      ],
    );
    setupTestConfig();
  });

  testWidgets('shows loading state initially', (tester) async {
    mockAttendanceNotifier.state = const AsyncValue.loading();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AttendanceHistoryScreen()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when no attendance records', (tester) async {
    mockAttendanceNotifier.state = const AsyncValue.data([]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AttendanceHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No attendance records found'), findsOneWidget);
  });

  testWidgets('displays attendance records correctly', (tester) async {
    final mockData = [
      {
        'course': TestData.mockCourse['title'],
        'code': TestData.mockCourse['code'],
        'attendance': [
          {
            'date': DateTime.now(),
            'status': 'present',
            'type': SessionType.course.toString(),
          },
        ],
      },
    ];

    mockAttendanceNotifier.state = AsyncValue.data(mockData);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AttendanceHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(TestData.mockCourse['title'] as String), findsOneWidget);
    expect(find.text(TestData.mockCourse['code'] as String), findsOneWidget);
    expect(find.text('PRESENT'), findsOneWidget);
  });

  testWidgets('filters attendance by session type', (tester) async {
    final mockData = [
      {
        'course': TestData.mockCourse['title'],
        'code': TestData.mockCourse['code'],
        'attendance': [
          {
            'date': DateTime.now(),
            'status': 'present',
            'type': SessionType.course.toString(),
          },
          {
            'date': DateTime.now(),
            'status': 'present',
            'type': SessionType.tp.toString(),
          },
        ],
      },
    ];

    mockAttendanceNotifier.state = AsyncValue.data(mockData);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AttendanceHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Initially shows all records
    expect(find.text(TestData.mockCourse['title'] as String), findsOneWidget);

    // Change filter to TP
    await tester.tap(find.text('TP'));
    await tester.pumpAndSettle();

    // Should show TP records
    expect(find.text('TP Session'), findsOneWidget);

    // Change filter to Course
    await tester.tap(find.text('COURSE'));
    await tester.pumpAndSettle();

    // Should show Course records
    expect(find.text('Course Session'), findsOneWidget);
  });

  testWidgets('shows error state correctly', (tester) async {
    mockAttendanceNotifier.state = AsyncValue.error(
      TestData.networkError,
      StackTrace.empty,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AttendanceHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Error: ${TestData.networkError}'), findsOneWidget);
  });

  testWidgets('updates when new data is available', (tester) async {
    // Start with empty data
    mockAttendanceNotifier.state = const AsyncValue.data([]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AttendanceHistoryScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No attendance records found'), findsOneWidget);

    // Update with new data
    final mockData = [
      {
        'course': TestData.mockCourse['title'],
        'code': TestData.mockCourse['code'],
        'attendance': [
          {
            'date': DateTime.now(),
            'status': 'present',
            'type': SessionType.course.toString(),
          },
        ],
      },
    ];

    mockAttendanceNotifier.state = AsyncValue.data(mockData);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(TestData.mockCourse['title'] as String), findsOneWidget);
    expect(find.text('PRESENT'), findsOneWidget);
  });
}
