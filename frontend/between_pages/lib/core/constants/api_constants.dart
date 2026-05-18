class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue:'http://10.0.2.2:8080/api', // Usa 10.0.2.2 para emuladores Android, 127.0.0.1 para iOS
    defaultValue: 'http://192.168.0.15:8080/api',
  );

  // JIKAN API (MyAnimeList - Unofficial)
  // Documentación: https://api.jikan.moe/v4/
  // Rate limits: 60 req/min, 3 req/seg
  static const String jikanBaseUrl = 'https://api.jikan.moe/v4';
  static const String jikanMangaSearch =
      '$jikanBaseUrl/manga'; // GET ?q={query}

  // AUTENTICACIÓN (/api/auth)
  static const login = '$baseUrl/auth/login';
  static const refresh = '$baseUrl/auth/refresh';
  static const me = '$baseUrl/auth/me';

  // USERS (/api/user)
  static const userRegister = '$baseUrl/user/register';
  static const user = '$baseUrl/user/';

  // BOOKS (/api/book)
  static const bookSearch = '$baseUrl/book/search';
  static const bookSearchLocal = '$baseUrl/book/search/local';
  static const book = '$baseUrl/book';

  // MANGA (/api/manga)
  static const mangaSearch = '$baseUrl/manga/search';
  static const mangaSearchLocal = '$baseUrl/manga/search/local';
  static const manga = '$baseUrl/manga';

  // FANFICTION (/api/fanfiction)
  static const fanficSearch = '$baseUrl/fanfiction/search';
  static const fanficStatus = '$baseUrl/fanfiction/status';
  static const fanfic = '$baseUrl/fanfiction';
  
  // CRAWLER EXTERNO (/api/crawler)
  static const ao3Crawler = '$baseUrl/crawler/ao3';

  // TAGS DE FANFICTION (/api/fanfiction/{fanficId}/tags)
  static const tagsFanfic =
      '$baseUrl/fanfiction/'; // Base para construir con el ID
  static const tagsAdd = '$baseUrl/fanfiction/{fanficId}/tags';
  static const tagsUpdate = '$baseUrl/fanfiction/{fanficId}/tags';
  static const tagsDelete = '$baseUrl/fanfiction/{fanficId}/tags/';
  static const tagsSearch = '$baseUrl/fanfiction/{fanficId}/tags/search';

  // MANGA EXTERNO (/api/external/manga)
  static const externalMangaSearch = '$baseUrl/external/manga/search';
  static const externalManga = '$baseUrl/external/manga';

  // LISTAS DE LECTURA (/api/lists)
  static const listCreate = '$baseUrl/lists';
  static const listUser = '$baseUrl/lists/user/';
  static const listGet = '$baseUrl/lists/';
  static const listUpdate = '$baseUrl/lists/';
  static const listDelete = '$baseUrl/lists/';
  static const listAddItem = '$baseUrl/lists/{listId}/items';
  static const listRemoveItem = '$baseUrl/lists/{listId}/items';

  // JOURNAL - BOOKS (/api/journal/BOOK)
  static const bookJournal = '$baseUrl/journal/book'; // POST (Minúsculas en el backend)
  static const bookJournalUser = '$baseUrl/journal/BOOK/user/';
  static const bookJournalUserStatus =
      '$baseUrl/journal/BOOK/user/{userId}/status';
  static const bookJournalUserRereadings =
      '$baseUrl/journal/BOOK/user/{userId}/rereadings';
  static const bookJournalDelete = '$baseUrl/journal/BOOK/'; // Para concatenar el ID al eliminar

  // JOURNAL - MANGA (/api/journal/MANGA)
  static const mangaJournal = '$baseUrl/journal/manga'; // POST
  static const mangaJournalUser = '$baseUrl/journal/MANGA/user/';
  static const mangaJournalUserStatus =
      '$baseUrl/journal/MANGA/user/{userId}/status';
  static const mangaJournalUserRereadings =
      '$baseUrl/journal/MANGA/user/{userId}/rereadings';
  static const mangaJournalDelete = '$baseUrl/journal/MANGA/';

  // JOURNAL - FANFICTION (/api/journal/FANFIC)
  static const fanficJournal = '$baseUrl/journal/fanfic'; // POST
  static const fanficJournalUser = '$baseUrl/journal/FANFIC/user/';
  static const fanficJournalUserStatus =
      '$baseUrl/journal/FANFIC/user/{userId}/status';
  static const fanficJournalUserRereadings =
      '$baseUrl/journal/FANFIC/user/{userId}/rereadings';
  static const fanficJournalDelete = '$baseUrl/journal/FANFIC/';

  // JOURNAL - READING SESSIONS (/api/reading-sessions)
  static const readingSessions = '$baseUrl/reading-sessions';

  // READING STATS (/api/reading-stats)
  static const readingStats = '$baseUrl/reading-stats';
  static const readingStatsGoal = '$baseUrl/reading-stats/goal';
  static const readingStatsStreak = '$baseUrl/reading-stats/streak';
  static const readingStatsActivity = '$baseUrl/reading-stats/activity';
}