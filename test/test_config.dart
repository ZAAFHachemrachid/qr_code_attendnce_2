import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_code_attendnce_2/core/config/app_config.dart';

/// Wraps a widget with necessary providers for testing
Widget testWrapper({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(overrides: overrides, child: MaterialApp(home: child));
}

/// Ensures app is in development mode for testing
void setupTestConfig() {
  AppConfig().initialize(environment: Environment.development);
}

/// Mock navigation observer for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/// Helper function to pump and settle with a timeout
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  bool timedOut = false;
  final timer = Timer(timeout, () => timedOut = true);

  while (timedOut != true) {
    await tester.pump(const Duration(milliseconds: 100));

    final found = tester.any(finder);
    if (found) {
      timer.cancel();
      break;
    }
  }

  if (timedOut) {
    throw Exception('Timed out waiting for ${finder.toString()}');
  }
}

/// Extension methods for widget testing
extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(testWrapper(child: widget));
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}

/// Mock storage for testing data persistence
class MockStorage extends Mock {
  final Map<String, dynamic> _data = {};

  void write(String key, dynamic value) => _data[key] = value;
  dynamic read(String key) => _data[key];
  void delete(String key) => _data.remove(key);
  void clear() => _data.clear();
}
