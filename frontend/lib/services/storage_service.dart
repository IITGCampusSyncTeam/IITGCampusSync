

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'authToken';

  // Write the token to secure storage
  Future<void> writeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Read the token from secure storage
  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete the token from secure storage
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}