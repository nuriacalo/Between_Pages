# Integración de Manga Externo (MyAnimeList vía Jikan)

Esta integración permite buscar manga desde **MyAnimeList** usando la API no oficial **Jikan**.

## 🏗️ Arquitectura

```
┌─────────────┐      ┌──────────────┐      ┌────────────────┐
│  Frontend   │ ───▶ │   Backend    │ ───▶ │  Jikan API     │
│   (Flutter) │      │  (Spring Boot) │      │ (MyAnimeList)  │
└─────────────┘      └──────────────┘      └────────────────┘
```

**¿Por qué pasar por el backend?**
- ✅ Consistente con Google Books (mismo patrón)
- ✅ Rate limiting controlado desde servidor
- ✅ Lógica de mapeo centralizada
- ✅ Facilita añadir más fuentes externas en el futuro

## Archivos creados

### Backend (Java)
| Archivo | Descripción |
|---------|-------------|
| `service/external/JikanService.java` | Servicio que consume Jikan API |
| `controller/external/ExternalMangaController.java` | Endpoints REST |

### Frontend (Dart)
| Archivo | Descripción |
|---------|-------------|
| `repositories/external_manga_repository.dart` | Repositorio que habla con nuestro backend |
| `providers/jikan_provider.dart` | Providers Riverpod (renombrados a `externalManga...`) |
| `widgets/external_manga_search.dart` | Widget de búsqueda funcional |

## Uso básico

### 1. Buscar manga

```dart
import 'package:between_pages/providers/jikan_provider.dart';

// Realizar búsqueda:
ref.read(externalMangaSearchProvider.notifier).searchManga('Attack on Titan');

// Observar resultados:
final results = ref.watch(externalMangaSearchResultsProvider);

// Ver estado de carga:
final isLoading = ref.watch(externalMangaSearchLoadingProvider);

// Ver errores:
final error = ref.watch(externalMangaSearchErrorProvider);
```

### 2. Usar el widget de búsqueda

```dart
import 'package:between_pages/widgets/external_manga_search.dart';

Scaffold(
  appBar: AppBar(title: Text('Buscar Manga')),
  body: ExternalMangaSearch(),
)
```

## Endpoints del backend

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/external/manga/search?query={q}&page={p}&limit={l}` | Buscar manga |
| GET | `/api/external/manga/{malId}` | Detalles por ID de MAL |

## Estados mapeados

| Estado Jikan | Estado App |
|--------------|------------|
| `publishing` | `ONGOING` |
| `finished` / `completed` | `COMPLETED` |
| `on_hiatus` | `PAUSED` |
| `discontinued` | `CANCELLED` |

## Notas importantes

1. **Fuente identificada**: El campo `source` es `'MyAnimeList (Jikan)'`
2. **ID**: `mangadex_id` será `null` porque Jikan usa MyAnimeList ID
3. **No requiere API key**: Jikan es pública, pero nuestro backend la protege

## Futuras mejoras

Para añadir más fuentes externas (MangaDex API, ComicVine, etc.):
1. Crear servicio en `service/external/`
2. Añadir endpoint en `controller/external/`
3. Opcional: Unificar en `ExternalMangaService` que combine resultados de múltiples fuentes
