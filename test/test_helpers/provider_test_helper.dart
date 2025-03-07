import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class for testing providers
class ProviderTestHelper {
  /// Creates an override for an auto-dispose provider
  static Override autoDisposeProvider<T>(T value) {
    return AutoDisposeProvider<T>(
      (ref) => value,
    ).overrideWithProvider(Provider((ref) => value));
  }

  /// Creates an override for a state provider
  static Override stateProvider<T>(T value) {
    return StateProvider<T>(
      (ref) => value,
    ).overrideWithProvider(Provider((ref) => value));
  }

  /// Creates an override for a state notifier provider
  static Override stateNotifierProvider<N extends StateNotifier<T>, T>(
    N notifier,
  ) {
    return StateNotifierProvider<N, T>(
      (ref) => notifier,
    ).overrideWithProvider(Provider((ref) => notifier));
  }

  /// Creates an override for a future provider
  static Override futureProvider<T>(Future<T> value) {
    return FutureProvider<T>(
      (ref) => value,
    ).overrideWithProvider(Provider((ref) => value));
  }

  /// Creates an override for a stream provider
  static Override streamProvider<T>(Stream<T> stream) {
    return StreamProvider<T>(
      (ref) => stream,
    ).overrideWithProvider(Provider((ref) => stream));
  }

  /// Creates an override for a family provider
  static Override familyProvider<T, P>(T Function(P) create) {
    return Provider.family<T, P>(
      (ref, param) => create(param),
    ).overrideWithProvider((param) => Provider((ref) => create(param)));
  }

  /// Creates a container with overrides for testing
  static ProviderContainer createContainer({
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) {
    final container = ProviderContainer(
      overrides: overrides,
      observers: observers,
    );

    // Add a listener to handle unhandled errors
    container.listen(
      Provider((ref) => null),
      (previous, next) {},
      onError: (error, stackTrace) {
        print('Unhandled provider error: $error');
        print(stackTrace);
      },
    );

    return container;
  }

  /// Creates a scoped provider container
  static ProviderScope createProviderScope({
    required Widget child,
    List<Override> overrides = const [],
    List<ProviderObserver>? observers,
  }) {
    return ProviderScope(
      overrides: overrides,
      observers: observers,
      child: child,
    );
  }

  /// Waits for a provider to emit a value that matches a condition
  static Future<T> waitForProvider<T>(
    ProviderContainer container,
    ProviderListenable<T> provider,
    bool Function(T) condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<T>();
    final subscription = container.listen(provider, (previous, next) {
      if (condition(next)) {
        completer.complete(next);
      }
    }, onError: completer.completeError);

    try {
      return await completer.future.timeout(timeout);
    } finally {
      subscription.close();
    }
  }

  /// Helper to create an async value for testing
  static AsyncValue<T> createAsyncValue<T>(T value) {
    return AsyncValue.data(value);
  }

  /// Helper to create an async error for testing
  static AsyncValue<T> createAsyncError<T>(
    Object error, [
    StackTrace? stackTrace,
  ]) {
    return AsyncValue.error(error, stackTrace ?? StackTrace.current);
  }

  /// Helper to create an async loading state for testing
  static AsyncValue<T> createAsyncLoading<T>() {
    return const AsyncValue.loading();
  }
}
