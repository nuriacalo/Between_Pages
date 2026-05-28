<div align="center">

# 📚 BetweenPages

**Plataforma full-stack unificada para el seguimiento de lectura multiformato.**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-F2F4F9?style=for-the-badge&logo=spring-boot)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Java 21](https://img.shields.io/badge/Java_21-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://jdk.java.net/21/)

> **Proyecto TFC (Trabajo de Fin de Ciclo) - DAM** <br>
> *Desarrollado por Nuria Calo Mosquera*

</div>

---

## 📑 Índice
- [El Problema que Resuelve](#-el-problema-que-resuelve)
- [Funcionalidades Principales](#-funcionalidades-principales)
- [Arquitectura del Sistema](#️-arquitectura-del-sistema)
- [Stack Tecnológico](#-stack-tecnológico)
- [Puesta en marcha local](#-puesta-en-marcha-local)
- [Endpoints principales](#-endpoints-principales-resumen)

## 🎯 El Problema que Resuelve
Soluciona la fragmentación existente entre plataformas como *Goodreads*, *MyAnimeList* y *AO3*. BetweenPages centraliza todo en un único ecosistema:
- **Biblioteca Unificada:** Libros, mangas y fanfics en un mismo lugar.
- **Automatización de Datos:** Integración con APIs externas y un web scraper propio para obtener metadatos sin esfuerzo.
- **Gamificación y Hábitos:** Registro de rachas, metas anuales y sesiones de lectura cronometradas.
- **Métricas Emocionales:** Va más allá de las estrellas, permitiendo registrar *Tear Drops* 💧, *Spice Flames* 🔥 y *Angst Level* 💔.

---

## ✨ Funcionalidades Principales

1. **Integraciones Externas y Crawler Propio 🌐**
   - **Google Books API:** Búsqueda e importación automática de libros.
   - **Jikan API (v4):** Obtención de metadatos de manga desde MyAnimeList.
   - **Crawler AO3 Integrado:** Extracción fiable de datos (título, autor, sinopsis, estado, ships) pegando simplemente el enlace de un fanfic.

2. **Journal Emocional de Lectura 📖**
   - Widgets personalizados para evaluar respuestas emocionales (EmojiRatingSelector, AngstLevelSelector).
   - Notas, citas favoritas y probabilidad de relectura.

3. **Listas Polimórficas 📋**
   - Colecciones personalizadas que pueden contener simultáneamente libros, mangas y fanfics.

4. **Gamificación y Sesiones ⏱️**
   - Cronómetro de lectura en vivo.
   - Seguimiento de rachas diarias y progreso hacia la meta anual.

5. **Seguridad Robusta 🛡️**
   - Autenticación JWT con Tokens de Acceso y Refresco.
   - Renovación asíncrona silenciosa (cola de peticiones en el Interceptor de Dio).
   - Almacenamiento cifrado en el dispositivo (`flutter_secure_storage`).

---

## 📱 Capturas de Pantalla

*(Reemplaza los enlaces de "via.placeholder.com" por las rutas de tus capturas reales)*
<p align="center">
  <img src="https://via.placeholder.com/250x500.png?text=Home+App" alt="Home" width="22%" />
  <img src="https://via.placeholder.com/250x500.png?text=Catálogo" alt="Catálogo" width="22%" />
  <img src="https://via.placeholder.com/250x500.png?text=Journal" alt="Journal" width="22%" />
  <img src="https://via.placeholder.com/250x500.png?text=Sesión+Lectura" alt="Sesion" width="22%" />
</p>

---

## ⚙️ Arquitectura del Sistema
El proyecto utiliza una estructura de **Monorepo** que aloja dos aplicaciones principales:
- 🔙 `backend/`: API REST desarrollada en Spring Boot.
- 📱 `frontend/between_pages/`: Aplicación multiplataforma en Flutter.

**Flujo general:**
1. **Cliente Flutter** maneja el estado reactivo con Riverpod y realiza peticiones seguras mediante Dio.
2. **API REST Spring Boot** actúa como middleware y procesador de lógica de negocio (seguridad, web scraping, integración de APIs).
3. **PostgreSQL** almacena los datos de manera relacional (y polimórfica para el contenido), con esquemas versionados mediante Flyway.

---

## 🛠 Stack Tecnológico

### Backend 🔙
- **Lenguaje & Framework:** Java 21, Spring Boot 3.3.1
- **Seguridad:** Spring Security + JWT (Access/Refresh Tokens)
- **Persistencia:** PostgreSQL, Spring Data JPA, Migraciones con **Flyway**
- **Documentación:** SpringDoc OpenAPI (Swagger)
- **Web Scraping:** Jsoup (Crawler AO3)

### Frontend 📱
- **Framework:** Flutter (Dart) - *Soporte multiplataforma (iOS, Android, Web)*
- **Gestor de Estado:** Riverpod
- **Enrutamiento:** GoRouter
- **Red:** Dio (con `AuthInterceptor` customizado)
- **Almacenamiento Local:** `flutter_secure_storage`, `shared_preferences`
- **UI/UX:** Material 3, Temas Claro/Oscuro, Internacionalización (gl, es, en)

---

## 📂 Estructura del repositorio
```graphql
📦 BetweenPages
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
└── frontend/between_pages/
    ├── lib/
    ├── android/
    ├── ios/
    ├── web/
    ├── windows/
    ├── macos/
    ├── linux/
    └── pubspec.yaml
```

---

## 🚀 Requisitos
- Java 21
- PostgreSQL 14+
- Flutter SDK compatible con `sdk: ^3.10.4`

---

## 💻 Puesta en marcha local

### 1️⃣ Base de datos
Crea una base de datos PostgreSQL:
```bash
createdb between_pages
```

### 2️⃣ Backend
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

Nota (Android emulator):
- usa `http://10.0.2.2:8080/api`

---

## Configuración
### Backend
`backend/src/main/resources/application.yaml`
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

### Frontend
La URL de API se define con:
- `--dart-define=API_BASE_URL=...`

Si no se define, el cliente usa el `defaultValue` en:
- `lib/core/constants/api_constants.dart`

---

## Seguridad y autenticación (JWT)
Endpoints principales:
- `POST /api/user/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `GET /api/auth/me`

Para endpoints protegidos:
- `Authorization: Bearer <token>`

---

## Endpoints principales (resumen)

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

### Tags (fanfiction)
- `GET /api/fanfiction/{fanficId}/tags`
- `POST /api/fanfiction/{fanficId}/tags?tag=...`
- `PUT /api/fanfiction/{fanficId}/tags`
- `DELETE /api/fanfiction/{fanficId}/tags/{tagId}`
- `GET /api/fanfiction/{fanficId}/tags/search?tag=...`

### Integraciones externas
- `GET /api/external/manga/search?query=...&page=1&limit=10`
- `GET /api/external/manga/{malId}`

### Journal
- `POST /api/journal/book`
- `GET /api/journal/BOOK/user/{userId}`
- `GET /api/journal/BOOK/user/{userId}/status?status=...`
- `GET /api/journal/BOOK/user/{userId}/rereadings`
- `DELETE /api/journal/BOOK/{journalId}`

- `POST /api/journal/manga`
- `GET /api/journal/MANGA/user/{userId}`
- `GET /api/journal/MANGA/user/{userId}/status?status=...`
- `GET /api/journal/MANGA/user/{userId}/rereadings`
- `DELETE /api/journal/MANGA/{journalId}`

- `POST /api/journal/fanfic`
- `GET /api/journal/FANFIC/user/{userId}`
- `GET /api/journal/FANFIC/user/{userId}/status?status=...`
- `GET /api/journal/FANFIC/user/{userId}/rereadings`
- `DELETE /api/journal/FANFIC/{journalId}`

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

---

## Calidad de código y tests
### Backend
```bash
cd backend
./mvnw test
```

### Frontend
```bash
cd frontend/between_pages
flutter analyze
flutter test
```

---

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

---

## Autoría
Nuria Calo — Proyecto TFC.
