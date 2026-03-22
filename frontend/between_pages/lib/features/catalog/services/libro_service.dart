// lib/features/catalog/services/libro_service.dart
import 'package:between_pages/core/api/api_constants.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../models/libro_model.dart';

class LibroService extends ChangeNotifier {
  List<LibroModel> _resultados = [];
  bool _cargando = false;
  String? _error;

  List<LibroModel> get resultados => _resultados;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> buscarEnGoogleBooks(String titulo) async {
    _cargando = true;
    _error = null;
    _resultados = [];
    notifyListeners();

    try {
      final data = await ApiClient.get(
        '${ApiConstants.buscarLibros}?q=$titulo',
      );
      _resultados = (data as List)
          .map((json) => LibroModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Error al buscar libros';
    }

    _cargando = false;
    notifyListeners();
  }

  Future<LibroModel?> guardarLibro(LibroModel libro) async {
    try {
    final data = await ApiClient.post(
  ApiConstants.guardarLibro,
  libro.toJson(),
);
      return LibroModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}