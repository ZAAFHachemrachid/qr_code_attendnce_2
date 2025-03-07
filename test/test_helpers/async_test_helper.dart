import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for testing async operations
class AsyncTestHelper {
  /// Pumps the widget tree until a specific condition is met or timeout
  static Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition() && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    if (!condition()) {
      throw Exception('Timed out waiting for condition after $timeout');
    }
  }

  /// Pumps the widget tree until a finder finds a widget or timeout
  static Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await pumpUntil(tester, () => tester.any(finder), timeout: timeout);
  }

  /// Creates a testable widget with providers
  static Widget createTestableWidget({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(overrides: overrides, child: MaterialApp(home: child));
  }
}

/// Extension methods for testing async providers
extension ProviderContainerAsyncX on ProviderContainer {
  /// Waits for a provider to emit a value that matches a condition
  Future<T> waitFor<T>(
    ProviderListenable<T> provider,
    bool Function(T) condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<T>();
    final subscription = listen(provider, (_, value) {
      if (condition(value)) {
        completer.complete(value);
      }
    }, fireImmediately: true);

    try {
      return await completer.future.timeout(timeout);
    } finally {
      subscription.close();
    }
  }

  /// Updates a provider's state and waits for the update to complete
  Future<void> updateAndWait<T>(
    StateNotifierProvider<StateNotifier<T>, T> provider,
    T Function(T) update, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final notifier = read(provider.notifier);
    final oldState = read(provider);
    final newState = update(oldState);

    (notifier as dynamic).state = newState;
  
    await waitFor(provider, (value) => value == newState, timeout: timeout);
  }
}

/// Extension methods for testing async widgets
extension WidgetTesterAsyncX on WidgetTester {
  /// Pumps a widget with error handling
  Future<void> safePump(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  }) async {
    try {
      await pump(duration, phase);
    } catch (e) {
      // Handle common test errors
      if (e.toString().contains('TickerMode')) {
        await pump(const Duration(milliseconds: 100));
      } else {
        rethrow;
      }
    }
  }

  /// Waits for a specific condition in the widget tree
  Future<void> waitFor(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await AsyncTestHelper.pumpUntil(this, condition, timeout: timeout);
  }

  /// Waits for a widget to appear in the tree
  Future<void> waitForWidget(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await AsyncTestHelper.pumpUntilFound(this, finder, timeout: timeout);
  }
}

/// Helper for testing providers
class TestProviderHelper {
  /// Creates a provider override that keeps the provider alive during tests
  static Override providerOverride<T>(T value) {
    return Provider.autoDispose<T>((ref) => value).overrideWithValue(value);
  }

  /// Creates a state notifier provider override for tests
  static Override stateNotifierOverride<T extends StateNotifier<State>, State>(
    T notifier,
  ) {
    return StateNotifierProvider.autoDispose<T, State>(
      (ref) => notifier,
    ).overrideWithValue(notifier);
  }
}
