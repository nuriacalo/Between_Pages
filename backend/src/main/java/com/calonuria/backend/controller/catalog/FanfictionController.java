package com.calonuria.backend.controller.catalog;

import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.service.catalog.FanfictionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del catálogo de fanfictions.
 */
@RestController
@RequestMapping("/api/fanfiction")
@Tag(name = "Catálogo de Fanfiction", description = "Endpoints para búsqueda y consulta de fanfictions")
public class FanfictionController {

    @Autowired
    private FanfictionService fanfictionService;

    @Operation(summary = "Buscar fanfics por título")
    @GetMapping("/search")
    public ResponseEntity<List<FanfictionResponseDTO>> searchByTitle(@RequestParam("q") String title) {
        return ResponseEntity.ok(fanfictionService.searchByTitle(title));
    }

    @Operation(summary = "Buscar fanfics por estado de publicación")
    @GetMapping("/status")
    public ResponseEntity<List<FanfictionResponseDTO>> searchByStatus(@RequestParam String status) {
        return ResponseEntity.ok(fanfictionService.searchByStatus(status));
    }

    @Operation(summary = "Obtener fanfic por ID")
    @GetMapping("/{id}")
    public ResponseEntity<FanfictionResponseDTO> getById(@PathVariable Long id) {
        return fanfictionService.getFanficById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @Operation(summary = "Guardar fanfic en base de datos local")
    @PostMapping
    public ResponseEntity<FanfictionResponseDTO> saveFanfic(@RequestBody FanfictionResponseDTO dto) {
        Fanfiction fanfic = new Fanfiction();
        fanfic.setAo3Id(dto.getAo3Id());
        fanfic.setTitle(dto.getTitle());
        fanfic.setAuthor(dto.getAuthor());
        fanfic.setSourceMaterial(dto.getSourceMaterial());
        fanfic.setDescription(dto.getDescription());
        fanfic.setCoverUrl(dto.getCoverUrl());
        fanfic.setGenre(dto.getGenre());
        fanfic.setMainShip(dto.getMainShip());
        fanfic.setTheme(dto.getTheme());
        fanfic.setCurrentChapter(dto.getCurrentChapter());
        fanfic.setTotalChapters(dto.getTotalChapters());
        fanfic.setPublicationStatus(dto.getPublicationStatus());
        return ResponseEntity.ok(fanfictionService.saveIfNotExists(fanfic));
    }
}