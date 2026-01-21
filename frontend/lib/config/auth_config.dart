class AuthConfig {
  static const String AZURE_TENANT_ID =
      String.fromEnvironment('AZURE_TENANT_ID', defaultValue: '');
  static const String CLIENT_ID =
      String.fromEnvironment('CLIENT_ID', defaultValue: '');
  static const String serverUrl =
      String.fromEnvironment('serverUrl', defaultValue: 'http://10.0.2.2:3000');
}
