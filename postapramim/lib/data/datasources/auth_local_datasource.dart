import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:posta_pra_mim/data/models/user_model.dart';

/// Persiste sessão localmente. Usa secure storage — nunca
/// SharedPreferences em plaintext para dados sensíveis.
abstract interface class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);

  Future<UserModel?> getUser();

  Future<void> clear();
}

final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveUser(UserModel user) {
    return _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clear() => _storage.delete(key: _userKey);
}
