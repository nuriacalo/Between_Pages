package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.service.MangaService;
import com.calonuria.backend.features.search.dto.MangaResponseDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/manga")
@Tag(name = "Catálogo de Mangas", description = "Endpoints para búsqueda y gestión de mangas en la base de datos local")
public class MangaController extends BaseCatalogController<Manga, MangaResponseDTO, Long, MangaService> {

    public MangaController(MangaService mangaService) {
        super(mangaService);
    }

    @Operation(summary = "Obtener todos los mangas del catálogo de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<MangaResponseDTO>> getMangasByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getMangasByUserId(userId));
    }

    @Operation(summary = "Buscar mangas en la base de datos local")
    @GetMapping("/search")
    @Override
    public ResponseEntity<List<MangaResponseDTO>> searchByTitle(@RequestParam(value = "q") String title) {
        if (title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.searchByTitle(title));
    }

    @Operation(summary = "Guardar un nuevo manga en el catálogo")
    @PostMapping
    public ResponseEntity<MangaResponseDTO> saveManga(@RequestBody MangaResponseDTO dto) {
        return ResponseEntity.ok(service.createManga(dto));
    }

    @Operation(summary = "Actualizar un manga existente")
    @PutMapping("/{id}")
    public ResponseEntity<MangaResponseDTO> updateManga(@PathVariable Long id, @RequestBody MangaResponseDTO dto) {
        return service.updateManga(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}