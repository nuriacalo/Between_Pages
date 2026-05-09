class JournalStatusHelper {
  static const List<String> statusOptions = [
    'Por leer',
    'Deseado',
    'Leyendo',
    'Pausado',
    'Terminado',
    'Abandonado',
  ];

  static String mapStatusToUi(String status) {
    return switch (status) {
      'TBR' => 'Por leer',
      'WISHLIST' => 'Deseado',
      'READING' => 'Leyendo',
      'FINISHED' => 'Terminado',
      'DROPPED' => 'Abandonado',
      'PAUSED' => 'Pausado',
      'PENDING' => 'Por leer',
      _ => status,
    };
  }

  static String mapStatusToDb(String status) {
    return switch (status) {
      'Por leer' => 'TBR',
      'Deseado' => 'WISHLIST',
      'Leyendo' => 'READING',
      'Terminado' => 'FINISHED',
      'Abandonado' => 'DROPPED',
      'Pausado' => 'PAUSED',
      _ => status,
    };
  }
}