import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

/// Exception thrown when attempting to access admin features on unsupported platforms
class UnsupportedPlatformException implements Exception {
  final String message;
  UnsupportedPlatformException(this.message);

  @override
  String toString() => 'UnsupportedPlatformException: $message';
}

/// Handles platform-specific configuration and validation for admin features
class AdminPlatformConfig {
  /// Checks if the current platform supports admin features
  static bool get isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      return false;
    }
  }

  /// Validates that the current platform can access admin features
  /// Throws [UnsupportedPlatformException] if the platform is not supported
  static void validatePlatform() {
    if (!isSupported) {
      throw UnsupportedPlatformException(
        'Admin features are only available on desktop platforms (Windows, macOS, Linux)',
      );
    }
  }

  /// Gets the minimum window size for the admin interface
  static Size get minWindowSize => const Size(1024, 768);

  /// Gets the recommended window size for the admin interface
  static Size get defaultWindowSize => const Size(1280, 800);

  /// Checks if the platform supports native menus
  static bool get supportsNativeMenus {
    if (!isSupported) return false;
    return Platform.isMacOS || Platform.isLinux;
  }

  /// Gets platform-specific window title
  static String get windowTitle => 'QR Attendance Admin Panel';
}
