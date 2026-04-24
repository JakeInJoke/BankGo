class DemoAuthCredentials {
  // Demo credentials should be injected at build time (dart-define).
  static const String dni = String.fromEnvironment('DEMO_DNI');
  static const String password = String.fromEnvironment('DEMO_PASSWORD');
  static const String pin = String.fromEnvironment('DEMO_PIN');

  static bool get hasConfiguredCredentials =>
      dni.trim().isNotEmpty && password.isNotEmpty;

  const DemoAuthCredentials._();
}
