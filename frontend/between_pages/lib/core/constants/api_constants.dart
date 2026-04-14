class ApiConstants {
  static const String baseUrl = 'http://192.168.0.14:8080/api';
  // 10.0.2.2 = localhost desde el emulador Android

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

  // LISTAS DE LECTURA (/api/reading-list)
  static const listCreate = '$baseUrl/reading-list';
  static const listUser = '$baseUrl/reading-list/user/';
  static const listGet = '$baseUrl/reading-list/';
  static const listUpdate = '$baseUrl/reading-list/';
  static const listDelete = '$baseUrl/reading-list/';
  static const listAddItem = '$baseUrl/reading-list/{listId}/items';
  static const listRemoveItem = '$baseUrl/reading-list/{listId}/items';

  // JOURNAL - BOOKS (/api/book-journal)
  static const bookJournal = '$baseUrl/book-journal';
  static const bookJournalUser = '$baseUrl/book-journal/user/';
  static const bookJournalUserStatus =
      '$baseUrl/book-journal/user/{userId}/status';
  static const bookJournalUserRereadings =
      '$baseUrl/book-journal/user/{userId}/rereadings';

  // JOURNAL - MANGA (/api/manga-journal)
  static const mangaJournal = '$baseUrl/manga-journal';
  static const mangaJournalUser = '$baseUrl/manga-journal/user/';
  static const mangaJournalUserStatus =
      '$baseUrl/manga-journal/user/{userId}/status';
  static const mangaJournalUserRereadings =
      '$baseUrl/manga-journal/user/{userId}/rereadings';

  // JOURNAL - FANFICTION (/api/fanfic-journal)
  static const fanficJournal = '$baseUrl/fanfic-journal';
  static const fanficJournalUser = '$baseUrl/fanfic-journal/user/';
  static const fanficJournalUserStatus =
      '$baseUrl/fanfic-journal/user/{userId}/status';
  static const fanficJournalUserRereadings =
      '$baseUrl/fanfic-journal/user/{userId}/rereadings';
}
