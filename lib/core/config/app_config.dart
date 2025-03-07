enum Environment {
  development,
  staging,
  production;

  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;

  static Environment fromString(String value) {
    return Environment.values.firstWhere(
      (env) => env.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Environment.production,
    );
  }
}

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  Environment _environment = Environment.production;
  bool _initialized = false;

  Environment get environment => _environment;
  bool get isDevelopment => _environment.isDevelopment;
  bool get isStaging => _environment.isStaging;
  bool get isProduction => _environment.isProduction;

  void initialize({Environment environment = Environment.production}) {
    if (_initialized) return;

    _environment = environment;
    _initialized = true;
  }

  // Feature flags
  bool get enableDevSignup => isDevelopment;
  bool get enableTestData => isDevelopment;
  bool get enablePerformanceMonitoring => !isDevelopment;
  bool get enableCrashReporting => !isDevelopment;
}
