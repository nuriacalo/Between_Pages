// lib/core/constants/api_constants.dart
class ApiConstants {

static const String baseUrl = 'http://10.0.2.2:8080/api';
  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String registro = '$baseUrl/usuario/registrar';

  // Catálogo
  static const String buscarLibros = '$baseUrl/libro/buscar';
  static const String guardarLibro = '$baseUrl/libro';
  static const String buscarMangas = '$baseUrl/manga/buscar';
  static const String buscarFanfics = '$baseUrl/fanfiction/buscar';

  // Journals
  static const String libroJournal = '$baseUrl/libro-journal';
  static const String mangaJournal = '$baseUrl/manga-journal';
  static const String fanficJournal = '$baseUrl/fanfic-journal';

  // Listas
  static const String listas = '$baseUrl/lista';
}