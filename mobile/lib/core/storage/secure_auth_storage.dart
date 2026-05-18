import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_keys.dart';

class SecureAuthStorage {
  const SecureAuthStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _instance = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static SecureAuthStorage get shared => const SecureAuthStorage(_instance);

  Future<void> saveToken(String token) =>
      _storage.write(key: StorageKeys.jwtToken, value: token);

  Future<String?> readToken() => _storage.read(key: StorageKeys.jwtToken);

  Future<void> saveUser({required String id, required String email}) async {
    await _storage.write(key: StorageKeys.userId, value: id);
    await _storage.write(key: StorageKeys.userEmail, value: email);
  }

  Future<({String id, String email})?> readUser() async {
    final id = await _storage.read(key: StorageKeys.userId);
    final email = await _storage.read(key: StorageKeys.userEmail);
    if (id == null || email == null) return null;
    return (id: id, email: email);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: StorageKeys.jwtToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userEmail);
  }
}
