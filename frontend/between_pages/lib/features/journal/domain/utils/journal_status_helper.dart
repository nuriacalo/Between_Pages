class JournalStatusHelper {
  static const List<String> statusOptions = [
    'Por leer',
    'Leyendo',
    'Pausado',
    'Terminado',
    'Abandonado',
  ];

  static String mapStatusToUi(String status) {
    return switch (status) {
      'TBR' => 'Por leer',
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
      'Leyendo' => 'READING',
      'Terminado' => 'FINISHED',
      'Abandonado' => 'DROPPED',
      'Pausado' => 'PAUSED',
      _ => status,
    };
  }
}