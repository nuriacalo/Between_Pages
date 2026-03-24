import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/auth_token_storage.dart';
import 'models/dto/journal/libro_journal_registro_dto.dart';
import 'services/libro_journal_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Between Pages',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const ApiDemoPage(),
    );
  }
}

class ApiDemoPage extends StatefulWidget {
  const ApiDemoPage({super.key});

  @override
  State<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends State<ApiDemoPage> {
  String _status = 'Listo';

  String _toLocalDateString(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _guardarProgreso() async {
    setState(() => _status = 'Enviando...');

    final tokenStorage = AuthTokenStorage();
    final api = ApiClient(
      baseUrl: 'http://10.0.2.2:8080',
      tokenStorage: tokenStorage,
    );
    final service = LibroJournalService(api);

    final hoy = DateTime.now();
    final dto = LibroJournalRegistroDTO(
      idUsuario: 1,
      idLibro: null,
      googleBooksId: 'GOOGLE_BOOKS_ID',
      titulo: 'Título de ejemplo',
      autor: 'Autor de ejemplo',
      isbn: null,
      editorial: null,
      descripcion: null,
      portadaUrl: null,
      genero: null,
      tipoLibro: null,
      anioPublicacion: null,
      estado: 'Leyendo',
      paginaActual: 10,
      valoracion: null,
      formatoLectura: 'Fisico',
      emociones: null,
      citasFavoritas: null,
      notaPersonal: null,
      fechaInicio: _toLocalDateString(hoy),
      fechaFin: null,
    );

    try {
      final res = await service.saveOrUpdateLibroJournal(dto);
      setState(() => _status = 'OK: idLibroJournal=${res.idLibroJournal}');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LibroJournal API Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_status),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _guardarProgreso,
              child: const Text('Guardar/Actualizar progreso'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nota: primero guarda el token con AuthTokenStorage.saveToken(...).',
            ),
          ],
        ),
      ),
    );
  }
}
