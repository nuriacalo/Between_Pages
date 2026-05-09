# BetweenPages
BetweenPages es una plataforma fullstack de seguimiento de lectura para **libros, manga y fanfiction**. Permite descubrir contenido, guardarlo en catálogo propio, registrar progreso, organizar listas y visualizar estadísticas personales de lectura.

## Qué resuelve la aplicación
BetweenPages está pensada para centralizar en un solo lugar lo que normalmente se lleva en varias apps/notas:
- Descubrimiento de obras (búsqueda externa + catálogo local).
- Seguimiento de progreso por tipo de contenido.
- Organización por listas personalizadas.
- Registro de hábitos (racha, metas, sesiones de lectura).
- Gestión de cuenta con autenticación JWT.

## Funcionalidades principales
### 1) Catálogo
- Gestión de **book**, **manga** y **fanfiction**.
- Consulta por ID, listado general y alta en base de datos.
- Búsqueda local y búsqueda externa según tipo.

### 2) Integraciones externas
- Google Books para búsqueda de libros.
- Jikan (MyAnimeList) para búsqueda de manga externo.

### 3) Journal de lectura
- Registro y actualización de progreso para cada tipo de obra.
- Estados de lectura, valoraciones y notas.
- Filtros por estado y consulta de relecturas.

### 4) Listas y organización
- Creación de listas personalizadas por usuario.
- Consulta de listas y eliminación.

### 5) Estadísticas y gamificación
- Meta anual de lectura.
- Racha de actividad.
- Registro de sesiones de lectura temporizadas.

### 6) Frontend multiplataforma
- Android, iOS, Web, Windows, macOS y Linux.
- Tema claro/oscuro.
- Internacionalización: español, inglés y gallego.

## Arquitectura
Repositorio monorepo con dos aplicaciones:
- `backend/`: API REST en Spring Boot.
- `frontend/between_pages/`: app Flutter.

Flujo general:
1. El usuario interactúa con Flutter.
2. Flutter consume la API REST (`/api/...`).
3. El backend persiste y consulta en PostgreSQL.
4. Para búsquedas externas se consulta Google Books o Jikan.

## Stack tecnológico
### Backend
- Java 21
- Spring Boot 3.3.1
- Spring Security + JWT
- Spring Data JPA
- PostgreSQL
- SpringDoc OpenAPI (Swagger)
- Maven Wrapper (`./mvnw`)

### Frontend
- Flutter + Dart
- Riverpod (estado)
- GoRouter (navegación)
- Dio (HTTP)
- Flutter Secure Storage + Shared Preferences
- Intl / Flutter Localizations

## Estructura del repositorio
```text
BetweenPages/
├── backend/
│   ├── src/main/java/com/calonuria/backend/
│   │   ├── config/
│   │   ├── controller/
│   │   ├── dto/
│   │   ├── model/
│   │   ├── repository/
│   │   ├── security/
│   │   └── service/
│   ├── src/main/resources/
│   │   ├── application.yaml
│   │   ├── application-dev.yaml
│   │   └── db/migration/
│   └── pom.xml
├── frontend/between_pages/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   ├── macos/
│   ├── linux/
│   └── pubspec.yaml
└── README.md
```

## Requisitos
- Java 21
- PostgreSQL 14+
- Flutter SDK compatible con `sdk: ^3.10.4`

## Puesta en marcha local
### 1) Base de datos
Crea una base de datos PostgreSQL:
```bash
createdb between_pages
```

### 2) Backend
Desde `backend/`:
```bash
./mvnw spring-boot:run
```

API disponible en:
- `http://localhost:8080`

Documentación:
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

### 3) Frontend
Desde `frontend/between_pages/`:
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
```

Nota Android emulator: usa `http://10.0.2.2:8080/api`.

## Configuración
### Variables backend (`backend/src/main/resources/application.yaml`)
- `DB_URL` (default: `jdbc:postgresql://localhost:5432/between_pages`)
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `JWT_REFRESH_EXPIRATION`
- `GOOGLE_BOOKS_API_KEY`
- `CORS_ORIGINS`
- `SERVER_PORT` (default: `8080`)
- `JPA_DDL_AUTO`
- `FLYWAY_ENABLED`
- `LOG_LEVEL`

### Configuración frontend
La URL de API se define con `--dart-define=API_BASE_URL=...`.
Si no se define, el cliente usa su `defaultValue` en `lib/core/constants/api_constants.dart`.

## Seguridad y autenticación
Auth basada en JWT:
- `POST /api/user/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `GET /api/auth/me`

Para endpoints protegidos:
- Header `Authorization: Bearer <token>`

En seguridad hay rutas públicas explícitas (registro, login, refresh, búsquedas y swagger) y el resto requiere autenticación.

## Endpoints principales (resumen funcional)
### Catálogo
- `GET /api/book/search?q=...`
- `GET /api/book/search/local?q=...`
- `GET /api/book/{id}`
- `GET /api/book`
- `POST /api/book`

- `GET /api/manga/search?q=...`
- `GET /api/manga/search/local?q=...`
- `GET /api/manga/{id}`
- `GET /api/manga`
- `POST /api/manga`

- `GET /api/fanfiction/search?q=...`
- `GET /api/fanfiction/status?status=...`
- `GET /api/fanfiction/{id}`
- `GET /api/fanfiction`
- `POST /api/fanfiction`

### Tags fanfiction
- `GET /api/fanfiction/{fanficId}/tags`
- `POST /api/fanfiction/{fanficId}/tags?tag=...`
- `PUT /api/fanfiction/{fanficId}/tags`
- `DELETE /api/fanfiction/{fanficId}/tags/{tagId}`
- `GET /api/fanfiction/{fanficId}/tags/search?tag=...`

### Integraciones externas
- `GET /api/external/manga/search?query=...&page=1&limit=10`
- `GET /api/external/manga/{malId}`

### Journal
- `POST /api/book-journal`
- `GET /api/book-journal/user/{userId}`
- `GET /api/book-journal/user/{userId}/status?status=...`
- `GET /api/book-journal/user/{userId}/rereadings`
- `DELETE /api/book-journal/{journalId}`

- `POST /api/manga-journal`
- `GET /api/manga-journal/user/{userId}`
- `GET /api/manga-journal/user/{userId}/status?status=...`
- `GET /api/manga-journal/user/{userId}/rereadings`
- `DELETE /api/manga-journal/{journalId}`

- `POST /api/fanfic-journal`
- `GET /api/fanfic-journal/user/{userId}`
- `GET /api/fanfic-journal/user/{userId}/status?status=...`
- `GET /api/fanfic-journal/user/{userId}/rereadings`
- `DELETE /api/fanfic-journal/{journalId}`

### Listas
- `GET /api/lists/user/{userId}`
- `POST /api/lists/user/{userId}`
- `DELETE /api/lists/{listId}`

### Estadísticas, gamificación y sesiones
- `GET /api/reading-stats/goal`
- `PUT /api/reading-stats/goal?targetAmount=...`
- `GET /api/reading-stats/streak`
- `POST /api/reading-stats/activity`

- `GET /api/gamification/stats`
- `POST /api/gamification/goal`

- `POST /api/reading-sessions`
- `GET /api/reading-sessions/stats?remainingPages=...`

## Calidad de código y tests
Backend:
```bash
cd backend
./mvnw test
```

Frontend:
```bash
cd frontend/between_pages
flutter analyze
flutter test
```

## Build de frontend
```bash
cd frontend/between_pages
flutter build apk
flutter build ios
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

## Autoría
Nuria Calo — Proyecto TFC.

