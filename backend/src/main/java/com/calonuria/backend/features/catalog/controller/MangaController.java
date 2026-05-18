package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.MangaResponseDTO;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.service.MangaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller that handles HTTP requests related to the Manga Catalog.
 * Extends {@link BaseCatalogController} to inherit standard CRUD operations
 * while providing manga-specific endpoints.
 * 
 * <p>Base path: {@code /api/manga}</p>
 */
@RestController
@RequestMapping("/api/manga")
@Tag(name = "Catálogo de Manga", description = "Endpoints para búsqueda y gestión de mangas en la base de datos local")
public class MangaController extends BaseCatalogController<Manga, MangaResponseDTO, Long, MangaService> {

    /**
     * Constructs a new {@code MangaController}.
     *
     * @param mangaService the service responsible for manga business logic.
     */
    public MangaController(MangaService mangaService) {
        super(mangaService);
    }

    /**
     * Searches for mangas in the local database by title.
     *
     * @param title the search query string (must not be empty)
     * @return a {@link ResponseEntity} containing a list of {@link MangaResponseDTO} matching the query,
     *         or a 400 Bad Request if the search string is empty.
     */
    @Operation(summary = "Buscar mangas en la base de datos local")
    @GetMapping("/search")
    @Override
    public ResponseEntity<List<MangaResponseDTO>> searchByTitle(@RequestParam(value = "q") String title) {
        if (title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.searchByTitle(title));
    }

    /**
     * Saves a new manga into the local catalog.
     *
     * @param dto the payload containing manga details to save
     * @return a {@link ResponseEntity} containing the saved {@link MangaResponseDTO}
     */
    @Operation(summary = "Guardar un nuevo manga en el catálogo")
    @PostMapping
    public ResponseEntity<MangaResponseDTO> saveManga(@RequestBody MangaResponseDTO dto) {
        return ResponseEntity.ok(service.createManga(dto));
    }

    /**
     * Updates an existing manga in the local catalog.
     *
     * @param id  the unique identifier of the manga to update
     * @param dto the payload containing updated manga details
     * @return a {@link ResponseEntity} containing the updated {@link MangaResponseDTO},
     *         or 404 Not Found if the manga does not exist.
     */
    @Operation(summary = "Actualizar un manga existente")
    @PutMapping("/{id}")
    public ResponseEntity<MangaResponseDTO> updateManga(@PathVariable Long id, @RequestBody MangaResponseDTO dto) {
        return service.updateManga(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
