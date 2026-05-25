import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:between_pages/features/notes/application/repositories/note_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Proveedor para obtener todas las notas globales del usuario.
/// Requiere que el backend tenga un endpoint que devuelva todas las notas.
final allNotesProvider = FutureProvider.autoDispose<List<NoteDTO>>((ref) async {
  try {
    final repo = ref.watch(noteRepositoryProvider);
    return await repo.getAllNotes();
  } catch (e) {
    throw Exception('Error al cargar todas las notas: $e');
  }
});