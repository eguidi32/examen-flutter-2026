class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'BADWALLET_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const Duration requestTimeout = Duration(seconds: 20);

  static const String walletsPath = '/api/wallets';
  static const String externalFacturesPath = '/api/external/factures';
}
