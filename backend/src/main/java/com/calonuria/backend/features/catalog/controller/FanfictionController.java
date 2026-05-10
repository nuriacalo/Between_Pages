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
@RequestMapping("/api/fanfiction")
@Tag(name = "Catálogo de Fanfiction", description = "Endpoints para búsqueda y gestión de fanfictions")
public class FanfictionController extends BaseCatalogController<Fanfiction, FanfictionResponseDTO, Long, FanfictionService> {

    public FanfictionController(FanfictionService fanfictionService) {
        super(fanfictionService);
    }

    @Operation(summary = "Buscar fanfics por estado de publicación")
    @GetMapping("/status")
    public ResponseEntity<List<FanfictionResponseDTO>> searchByStatus(@RequestParam String status) {
        // Asumimos que el servicio tiene un método para buscar por estado.
        return ResponseEntity.ok(service.searchByStatus(status));
    }

    @Operation(summary = "Guardar un nuevo fanfic en el catálogo")
    @PostMapping
    public ResponseEntity<FanfictionResponseDTO> saveFanfic(@RequestBody FanfictionResponseDTO dto) {
        // Asumimos que el servicio tiene un método para manejar esto.
        return ResponseEntity.ok(service.saveFromDTO(dto));
    }

    @Operation(summary = "Actualizar un fanfic existente")
    @PutMapping("/{id}")
    public ResponseEntity<FanfictionResponseDTO> updateFanfic(@PathVariable Long id, @RequestBody FanfictionResponseDTO dto) {
        return service.updateFanfic(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
