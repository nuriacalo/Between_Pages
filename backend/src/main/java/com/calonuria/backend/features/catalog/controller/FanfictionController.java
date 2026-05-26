package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.service.FanfictionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/fanfic")
@Tag(name = "Catálogo de Fanfics", description = "Endpoints para búsqueda y gestión de fanfics en la base de datos local")
public class FanfictionController extends BaseCatalogController<Fanfiction, FanfictionResponseDTO, Long, FanfictionService> {

    public FanfictionController(FanfictionService fanfictionService) {
        super(fanfictionService);
    }

    @Operation(summary = "Obtener todos los fanfics del catálogo de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<FanfictionResponseDTO>> getFanficsByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(service.getFanficsByUserId(userId));
    }

    @Operation(summary = "Buscar fanfics en la base de datos local")
    @GetMapping("/search")
    @Override
    public ResponseEntity<List<FanfictionResponseDTO>> searchByTitle(@RequestParam(value = "q") String title) {
        if (title.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(service.searchByTitle(title));
    }

    @Operation(summary = "Guardar un nuevo fanfic en el catálogo")
    @PostMapping
    public ResponseEntity<FanfictionResponseDTO> saveFanfic(@RequestBody FanfictionResponseDTO dto) {
        return ResponseEntity.ok(service.createFanfic(dto));
    }

    @Operation(summary = "Actualizar un fanfic existente")
    @PutMapping("/{id}")
    public ResponseEntity<FanfictionResponseDTO> updateFanfic(@PathVariable Long id, @RequestBody FanfictionResponseDTO dto) {
        return service.updateFanfic(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}