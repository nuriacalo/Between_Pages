// lib/features/auth/services/auth_service.dart
import 'package:between_pages/core/api/api_constants.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/usuario_model.dart';

class AuthService extends ChangeNotifier {
  UsuarioModel? _usuario;
  bool _cargando = false;
  String? _error;

  UsuarioModel? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;

  Future<bool> login(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiClient.post(
        ApiConstants.login,
        {'email': email, 'password': password},
        auth: false,
      );

      _usuario = UsuarioModel.fromJson(data);
      await ApiClient.guardarToken(_usuario!.token);
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Email o contraseña incorrectos';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registro(String nombre, String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await ApiClient.post(
        ApiConstants.registro,
        {'nombre': nombre, 'email': email, 'password': password},
        auth: false,
      );
      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al registrarse. El email puede estar en uso.';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.eliminarToken();
    _usuario = null;
    notifyListeners();
  }
}