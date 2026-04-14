package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.service.catalog.MangaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del catálogo de mangas.
 */
@RestController
@RequestMapping("/api/manga")
@Tag(name = "Catálogo de Manga", description = "Endpoints para búsqueda en MangaDex y base de datos local")
public class MangaController {

    @Autowired
    private MangaService mangaService;

    @Operation(summary = "Buscar mangas en MangaDex")
    @GetMapping("/search")
    public ResponseEntity<List<MangaResponseDTO>> searchInMangaDex(@RequestParam("q") String title) {
        return ResponseEntity.ok(mangaService.searchInMangaDex(title));
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

    @Operation(summary = "Guardar manga en base de datos local")
    @PostMapping
    public ResponseEntity<MangaResponseDTO> saveManga(@RequestBody MangaResponseDTO dto) {
        Manga manga = new Manga();
        manga.setMangadexId(dto.getMangadexId());
        manga.setSource("MangaDex");
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