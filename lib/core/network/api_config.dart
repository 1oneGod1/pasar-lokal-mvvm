class ApiConfig {
  const ApiConfig._();

  /// Base URL for the Go backend.
  ///
  /// For Android emulator, use host loopback via 10.0.2.2.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8081',
  );
}
