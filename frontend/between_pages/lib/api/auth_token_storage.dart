import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro de tokens JWT usando flutter_secure_storage.
/// Los tokens nunca se guardan en SharedPreferences ni en almacenamiento no cifrado.
class AuthTokenStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final _tokenChangeController = StreamController<void>.broadcast();

  /// Stream que se emite cada vez que el token cambia (guardado o eliminado)
  Stream<void> get onTokenChanged => _tokenChangeController.stream;

  /// Guarda el token de acceso de forma segura
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _tokenChangeController.add(null);
  }

  /// Lee el token de acceso almacenado de forma segura
  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el token de acceso
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
    _tokenChangeController.add(null);
  }

  /// Guarda el refresh token de forma segura
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Lee el refresh token almacenado
  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Elimina el refresh token
  Future<void> removeRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Elimina todos los tokens (logout completo)
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
    _tokenChangeController.add(null);
  }
}
