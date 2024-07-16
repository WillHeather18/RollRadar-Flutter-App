import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<String?> getLocalApiKey() async {
    return await secureStorage.read(key: 'apiKey');
  }

  static Future<String?> getLocalOauthClientId() async {
    return await secureStorage.read(key: 'oauthClientId');
  }

  static Future<String?> getLocalOauthClientSecret() async {
    return await secureStorage.read(key: 'oauthClientSecret');
  }

  static Future<void> setLocalApiKey(String key) async {
    await secureStorage.write(key: 'apiKey', value: key);
  }

  static Future<void> setLocalOauthClientId(String clientId) async {
    await secureStorage.write(key: 'oauthClientId', value: clientId);
  }

  static Future<void> setLocalOauthClientSecret(String clientSecret) async {
    await secureStorage.write(key: 'oauthClientSecret', value: clientSecret);
  }
}
