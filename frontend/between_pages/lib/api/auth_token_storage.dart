import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  static const _tokenKey = 'auth_token';
  final _tokenChangeController = StreamController<void>.broadcast();

  /// Stream que se emite cada vez que el token cambia (guardado o eliminado)
  Stream<void> get onTokenChanged => _tokenChangeController.stream;

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _tokenChangeController.add(null);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _tokenChangeController.add(null);
  }
}
