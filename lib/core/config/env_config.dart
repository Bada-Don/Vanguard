/// Environment configuration for the application
/// Manages different configurations for dev, staging, and production environments
class EnvConfig {
  final String environment;
  final String apiBaseUrl;
  final String apiKey;
  final String serviceId;
  final String logLevel;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.apiKey,
    required this.serviceId,
    required this.logLevel,
  });

  /// Development environment configuration
  static const EnvConfig development = EnvConfig(
    environment: 'development',
    apiBaseUrl: 'http://localhost:3000/api/v1',
    apiKey: 'dev_key_12345',
    serviceId: 'com.vanguard.crisis.dev',
    logLevel: 'DEBUG',
  );

  /// Staging environment configuration
  static const EnvConfig staging = EnvConfig(
    environment: 'staging',
    apiBaseUrl: 'https://staging-api.vanguard-crisis.com/api/v1',
    apiKey: 'staging_key_67890',
    serviceId: 'com.vanguard.crisis.staging',
    logLevel: 'INFO',
  );

  /// Production environment configuration
  static const EnvConfig production = EnvConfig(
    environment: 'production',
    apiBaseUrl: 'https://api.vanguard-crisis.com/api/v1',
    apiKey: 'prod_key_placeholder', // Should be loaded from secure storage
    serviceId: 'com.vanguard.crisis',
    logLevel: 'WARNING',
  );

  /// Current active configuration (defaults to development)
  static const EnvConfig current = development;
}
