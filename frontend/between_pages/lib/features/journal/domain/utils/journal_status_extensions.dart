

import 'package:between_pages/features/journal/domain/utils/journal_status_helper.dart';

/// Helpers para reducir duplicación de comparaciones por strings.
///
/// Úsalos como: 
///   if (status.isReading) { ... }
///   final label = status.uiLabel;
extension JournalStatusX on String? {
  bool get isTbr => this == 'TBR';

  bool get isReading => this == 'READING';

  bool get isFinished => this == 'FINISHED';

  bool get isPaused => this == 'PAUSED';

  bool get isWishlist => this == 'WISHLIST';

  bool get isDropped => this == 'DROPPED';

  bool get isInProgress => isReading || isPaused || isTbr || isWishlist;

  /// Convierte el status DB a etiqueta UI (ej. 'READING' -> 'Leyendo').
  String get uiLabel => this == null ? '' : JournalStatusHelper.mapStatusToUi(this!);

  /// Convierte el status UI a status DB. 
  /// Normalmente lo usarías desde pantallas de edición.
  String get dbStatus => this == null ? '' : JournalStatusHelper.mapStatusToDb(this!);
}

