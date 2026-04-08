class ApiConstants {
  static const String baseUrl = 'http://192.168.0.17:8080/api';
  // 10.0.2.2 = localhost desde el emulador Android

  // AUTENTICACIÓN (/api/auth)
  static const login = '$baseUrl/auth/login';
  static const refresh = '$baseUrl/auth/refresh';
  static const me = '$baseUrl/auth/me';

  // USUARIOS (/api/usuario)
  static const usuarioRegistrar = '$baseUrl/usuario/registrar';
  static const usuario = '$baseUrl/usuario/';

  // FANFICTION (/api/fanfiction)
  static const fanficBuscar = '$baseUrl/fanfiction/buscar';
  static const fanficEstado = '$baseUrl/fanfiction/estado';
  static const fanficBuscarLocal = '$baseUrl/fanfiction/buscar/local';
  static const fanfic = '$baseUrl/fanfiction'; // Base para GET por ID, POST, etc.

  // LIBROS (/api/libro)
  static const libroBuscar = '$baseUrl/libro/buscar';
  static const libroBuscarLocal = '$baseUrl/libro/buscar/local';
  static const libro = '$baseUrl/libro'; // Base para GET por ID, POST, etc.

  // MANGA (/api/manga)
  static const mangaBuscar = '$baseUrl/manga/buscar';
  static const mangaBuscarLocal = '$baseUrl/manga/buscar/local';
  static const manga = '$baseUrl/manga'; // Base para GET por ID, POST, etc.

  // TAGS FANFICTION (/api/fanfiction/{idFanfic}/tags)
  static const tagsFanfic = '$baseUrl/fanfiction/';           // GET {id}/tags
  static const tagsAdd = '$baseUrl/fanfiction/{id}/tags';     // POST ?tag=
  static const tagsUpdate = '$baseUrl/fanfiction/{id}/tags';  // PUT
  static const tagsDelete = '$baseUrl/fanfiction/{id}/tags/'; // DELETE {idTag}
  static const tagsBuscar = '$baseUrl/fanfiction/{id}/tags/buscar'; // GET ?tag=

  // JOURNAL - FANFICTION (/api/fanfic-journal)
  static const fanficJournalCreate = '$baseUrl/fanfic-journal';      // POST
  static const fanficJournalUser = '$baseUrl/fanfic-journal/usuario/'; // GET {idUsuario}

  // JOURNAL - LIBROS (/api/libro-journal)
  static const libroJournalCreate = '$baseUrl/libro-journal';        // POST
  static const libroJournalUser = '$baseUrl/libro-journal/usuario/'; // GET {idUsuario}

  // JOURNAL - MANGA (/api/manga-journal)
  static const mangaJournalCreate = '$baseUrl/manga-journal';        // POST
  static const mangaJournalUser = '$baseUrl/manga-journal/usuario/'; // GET {idUsuario}

  // LISTAS PERSONALIZADAS (/api/lista)
  static const listaCreate = '$baseUrl/lista';           // POST
  static const listaUser = '$baseUrl/lista/usuario/';    // GET {idUsuario}
  static const listaGet = '$baseUrl/lista/';             // GET {id}
  static const listaUpdate = '$baseUrl/lista/';          // PUT {idLista}
  static const listaDelete = '$baseUrl/lista/';          // DELETE {idLista}
  static const listaAddItem = '$baseUrl/lista/{idLista}/items'; // POST ?tipo=&idItem=
  static const listaRemoveItem = '$baseUrl/lista/{idLista}/items'; // DELETE ?tipo=&idItem=
}
