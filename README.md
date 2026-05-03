# BetweenPages

BetweenPages es una plataforma fullstack de seguimiento de lectura que permite a los usuarios gestionar y organizar sus libros, mangas y fanfictions desde cualquier dispositivo.

## 📋 Descripción

Este proyecto es un TFC (Trabajo Final de Ciclo) compuesto por un **backend API REST** y una **aplicación frontend multiplataforma** que proporciona:

- **Catálogo de contenido**: Gestión de libros, mangas y fanfictions con metadatos enriquecidos
- **Búsqueda integrada**: Búsqueda de libros vía Google Books API y mangas vía Jikan API (MyAnimeList)
- **Journal de lectura**: Seguimiento personal del progreso de lectura con estados, formatos y puntuaciones
- **Listas personalizadas**: Organización de contenido en listas de lectura
- **Estadísticas de lectura**: Metas, rachas (streaks) y actividad del usuario
- **Gestión de usuarios**: Registro, autenticación JWT con refresh tokens y perfiles

## ✨ Funcionalidades Principales

| Módulo | Funcionalidades |
|--------|-----------------|
| **Catálogo** | Libros, mangas y fanfictions con portadas, autores, géneros y sinopsis |
| **Búsqueda** | Búsqueda unificada con resultados de APIs externas (Google Books, Jikan) |
| **Journal** | Registro de lectura con estado (leyendo, completado, pausado...), formato (físico, digital, audiobook), progreso, valoraciones y notas |
| **Listas** | Creación de listas personalizadas para organizar obras |
| **Estadísticas** | Metas de lectura, rachas diarias, resumen de actividad |
| **Autenticación** | Registro, login, tokens JWT con expiración y refresh tokens |
| **Multiidioma** | Soporte para español, inglés y gallego |
| **Tema visual** | Modo claro y oscuro adaptable |

## 🛠️ Tecnologías

### Backend
- **Java 21**
- **Spring Boot 3.3.1**
- **Spring Security** – Autenticación y autorización con JWT
- **Spring Data JPA** – Persistencia de datos
- **PostgreSQL** – Base de datos relacional
- **Flyway** – Migraciones de base de datos
- **SpringDoc OpenAPI** – Documentación interactiva de la API
- **Lombok** – Reducción de código boilerplate
- **Maven** – Gestión de dependencias

### Frontend
- **Flutter 3.x** – Framework multiplataforma
- **Dart**
- **Riverpod** – Gestión de estado reactiva
- **GoRouter** – Navegación declarativa
- **Dio** – Cliente HTTP
- **Flutter Secure Storage + Shared Preferences** – Almacenamiento seguro y local
- **Cached Network Image** – Caché de imágenes
- **Flutter Rating Bar + Shimmer** – UI/UX enriquecida
- **Intl + Flutter Localizations** – Internacionalización
- **Google Fonts** – Tipografía personalizada

## 📁 Estructura del Proyecto

```
BetweenPages/
├── backend/
│   ├── src/main/java/com/calonuria/backend/
│   │   ├── config/              # Configuración de Spring (seguridad, CORS, OpenAPI, Google Books)
│   │   ├── controller/          # Controladores REST
│   │   │   ├── auth/            # Autenticación
│   │   │   ├── catalog/         # Libros, mangas, fanfictions, tags
│   │   │   ├── external/        # Integración con APIs externas
│   │   │   ├── journal/         # Seguimiento de lectura
│   │   │   ├── list/            # Listas personalizadas
│   │   │   └── user/            # Usuarios y estadísticas
│   │   ├── dto/                 # Data Transfer Objects
│   │   ├── model/               # Entidades JPA
│   │   ├── repository/          # Repositorios Spring Data
│   │   ├── security/            # Filtro JWT y utilidades
│   │   └── service/             # Lógica de negocio y servicios externos
│   ├── src/main/resources/
│   │   ├── application.yaml     # Configuración principal
│   │   ├── application-dev.yaml # Perfil de desarrollo
│   │   └── db/migration/        # Scripts Flyway
│   └── pom.xml
│
├── frontend/
│   └── between_pages/
│       ├── lib/
│       │   ├── api/             # Cliente HTTP, interceptores y almacenamiento de tokens
│       │   ├── controllers/     # Controladores de autenticación
│       │   ├── core/            # Constantes, router y temas
│       │   ├── l10n/            # Traducciones (es, en, gl)
│       │   ├── models/          # Modelos de datos (DTOs)
│       │   ├── providers/       # Proveedores Riverpod
│       │   ├── repositories/    # Acceso a datos
│       │   ├── screens/         # Pantallas de la aplicación
│       │   └── widgets/         # Componentes reutilizables
│       ├── android/             # Configuración Android
│       ├── ios/                 # Configuración iOS
│       ├── web/                 # Configuración Web
│       ├── windows/             # Configuración Windows
│       ├── macos/               # Configuración macOS
│       ├── linux/               # Configuración Linux
│       └── pubspec.yaml
│
└── README.md
```

## 🚀 Instalación y Configuración

### Prerrequisitos

- **Backend**:
  - Java 21 o superior
  - PostgreSQL 14+
  - Maven (o usar `./mvnw` incluido)
- **Frontend**:
  - Flutter SDK 3.10.4+
  - Android Studio / Xcode (para emuladores)
  - Navegador Chrome/Edge (para web)

### Variables de Entorno (Backend)

Puedes configurarlas como variables de entorno del sistema o directamente en `backend/src/main/resources/application.yaml`:

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `DB_URL` | URL de conexión a PostgreSQL | `jdbc:postgresql://localhost:5432/between_pages` |
| `DB_USERNAME` | Usuario de la base de datos | `postgres` |
| `DB_PASSWORD` | Contraseña de la base de datos | `secret` |
| `JWT_SECRET` | Clave secreta para firmar tokens JWT | `miClaveSecretaMuySegura` |
| `JWT_EXPIRATION` | Tiempo de expiración del access token (ms) | `86400000` (24h) |
| `JWT_REFRESH_EXPIRATION` | Tiempo de expiración del refresh token (ms) | `604800000` (7 días) |
| `GOOGLE_BOOKS_API_KEY` | API Key de Google Books | `AIza...` |
| `CORS_ORIGINS` | Orígenes permitidos para CORS | `http://localhost:5173,http://localhost:3000` |
| `SERVER_PORT` | Puerto del servidor | `8080` |
| `JPA_DDL_AUTO` | Estrategia de DDL de Hibernate | `validate` (recomendado) |
| `FLYWAY_ENABLED` | Habilitar migraciones Flyway | `true` |

### Configuración de Base de Datos

1. Crear la base de datos en PostgreSQL:
```bash
createdb between_pages
```

2. Flyway ejecutará automáticamente las migraciones al iniciar la aplicación.

### Ejecutar el Backend

```bash
cd backend
./mvnw spring-boot:run
```

La API estará disponible en: `http://localhost:8080/api`

### Ejecutar el Frontend

```bash
cd frontend/between_pages

# Dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run

# Ejecutar en un dispositivo/emulador específico
flutter run -d <device_id>

# Compilar para producción
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
flutter build macos        # macOS
flutter build linux        # Linux
```

## 📚 Documentación de la API

Una vez el backend esté en ejecución, accede a la documentación interactiva (Swagger UI):

```
http://localhost:8080/api/swagger-ui.html
```

También está disponible la especificación OpenAPI en:

```
http://localhost:8080/api/v3/api-docs
```

## 🔐 Autenticación

La API utiliza JWT (JSON Web Tokens) con refresh tokens:

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/auth/registro` | `POST` | Registro de nuevos usuarios |
| `/api/auth/login` | `POST` | Inicio de sesión |
| `/api/auth/refresh` | `POST` | Renovación del access token |

Las peticiones autenticadas deben incluir el header:
```
Authorization: Bearer <access_token>
```

## 📝 Endpoints Principales

> Todos los endpoints están bajo el prefijo `/api`

### Catálogo
- **Libros**: `GET/POST /api/libros`
- **Mangas**: `GET/POST /api/mangas`
- **Fanfictions**: `GET/POST /api/fanfictions`
- **Tags de Fanfic**: `GET /api/fanfic-tags`

### Búsqueda Externa
- **Libros (Google Books)**: `GET /api/external/libros/buscar?titulo={titulo}`
- **Mangas (Jikan)**: `GET /api/external/mangas/buscar?titulo={titulo}`

### Journal (Seguimiento de Lectura)
- **Journal de Libros**: `GET/POST /api/journal/libros`
- **Journal de Mangas**: `GET/POST /api/journal/mangas`
- **Journal de Fanfics**: `GET/POST /api/journal/fanfics`

### Listas
- **Listas del usuario**: `GET /api/listas`
- **Crear lista**: `POST /api/listas`
- **Detalle de lista**: `GET /api/listas/{id}`

### Usuarios y Estadísticas
- **Perfil**: `GET /api/usuarios/me`
- **Estadísticas**: `GET /api/usuarios/estadisticas`
- **Meta de lectura**: `GET/PUT /api/usuarios/meta-lectura`
- **Racha de lectura**: `GET /api/usuarios/racha`

## 🌍 Plataformas Soportadas

| Plataforma | Estado |
|------------|--------|
| Android | ✅ Soporte completo |
| iOS | ✅ Soporte completo |
| Web | ✅ Soporte completo |
| Windows | ✅ Soporte completo |
| macOS | ✅ Soporte completo |
| Linux | ✅ Soporte completo |

## 🔗 Integraciones Externas

- **Google Books API**: Búsqueda y enriquecimiento de metadatos de libros
- **Jikan API (MyAnimeList)**: Búsqueda y enriquecimiento de metadatos de manga

## 🌐 Internacionalización

La aplicación frontend soporta tres idiomas:
- 🇪🇸 Español (`es`)
- 🇬🇧 Inglés (`en`)
- 🏴󠁥󠁳󠁧󠁡󠁿 Gallego (`gl`)

## 👨‍💻 Autor

**Nuria Calo** — Proyecto TFC

