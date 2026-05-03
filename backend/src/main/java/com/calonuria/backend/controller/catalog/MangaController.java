package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.service.catalog.MangaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del catálogo de mangas.
 */
@RestController
@RequestMapping("/api/manga")
@Tag(name = "Catálogo de Manga", description = "Endpoints para búsqueda en MyAnimeList (Jikan) y base de datos local")
public class MangaController {

    private final MangaService mangaService;

    public MangaController(MangaService mangaService) {
        this.mangaService = mangaService;
    }

    @Operation(summary = "Buscar mangas en MyAnimeList (Jikan)")
    @GetMapping("/search")
    public ResponseEntity<List<MangaResponseDTO>> searchInJikan(@RequestParam("q") String title) {
        return ResponseEntity.ok(mangaService.searchInJikan(title));
    }

    @Operation(summary = "Buscar mangas en base de datos local")
    @GetMapping("/search/local")
    public ResponseEntity<List<MangaResponseDTO>> searchInDatabase(@RequestParam("q") String title) {
        return ResponseEntity.ok(mangaService.searchInDatabase(title));
    }

    @Operation(summary = "Obtener manga por ID")
    @GetMapping("/{id}")
    public ResponseEntity<MangaResponseDTO> getById(@PathVariable Long id) {
        return mangaService.getMangaById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @Operation(summary = "Obtener todos los mangas de la base de datos")
    @GetMapping
    public ResponseEntity<List<MangaResponseDTO>> getAll() {
        return ResponseEntity.ok(mangaService.getAllMangas());
    }

    @Operation(summary = "Guardar manga en base de datos local")
    @PostMapping
    public ResponseEntity<MangaResponseDTO> saveManga(@RequestBody MangaResponseDTO dto) {
        Manga manga = new Manga();
        manga.setMalId(dto.getMalId());
        manga.setSource("MyAnimeList");
        manga.setTitle(dto.getTitle());
        manga.setAuthor(dto.getAuthor());
        manga.setDemographic(dto.getDemographic());
        manga.setGenre(dto.getGenre());
        manga.setDescription(dto.getDescription());
        manga.setCoverUrl(dto.getCoverUrl());
        manga.setTotalChapters(dto.getTotalChapters());
        manga.setTotalVolumes(dto.getTotalVolumes());
        manga.setPublicationStatus(dto.getPublicationStatus());
        return ResponseEntity.ok(mangaService.saveIfNotExists(manga));
    }
}