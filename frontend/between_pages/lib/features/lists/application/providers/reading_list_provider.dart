import 'package:between_pages/features/lists/application/providers/list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legacy provider.
///
/// Mantiene compatibilidad con código antiguo que usaba
/// `userReadingListsProvider` en lugar de `listProvider`.
final userReadingListsProvider = listProvider;


