package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.service.FanfictionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller that handles HTTP requests related to the Fanfiction Catalog.
 * Extends {@link BaseCatalogController} to inherit standard CRUD operations
 * while providing fanfiction-specific endpoints.
 * 
 * <p>Base path: {@code /api/fanfiction}</p>
 */
@RestController
@RequestMapping("/api/fanfiction")
@Tag(name = "Catálogo de Fanfiction", description = "Endpoints para búsqueda y gestión de fanfictions")
public class FanfictionController extends BaseCatalogController<Fanfiction, FanfictionResponseDTO, Long, FanfictionService> {

    /**
     * Constructs a new {@code FanfictionController}.
     *
     * @param fanfictionService the service responsible for fanfiction business logic.
     */
    public FanfictionController(FanfictionService fanfictionService) {
        super(fanfictionService);
    }

    /**
     * Searches for fanfictions in the local database by publication status.
     *
     * @param status the publication status query string (e.g., 'ONGOING', 'COMPLETED')
     * @return a {@link ResponseEntity} containing a list of {@link FanfictionResponseDTO} matching the status
     */
    @Operation(summary = "Buscar fanfics por estado de publicación")
    @GetMapping("/status")
    public ResponseEntity<List<FanfictionResponseDTO>> searchByStatus(@RequestParam String status) {
        // Asumimos que el servicio tiene un método para buscar por estado.
        return ResponseEntity.ok(service.searchByStatus(status));
    }

    /**
     * Saves a new fanfiction into the local catalog.
     *
     * @param dto the payload containing fanfiction details to save
     * @return a {@link ResponseEntity} containing the saved {@link FanfictionResponseDTO}
     */
    @Operation(summary = "Guardar un nuevo fanfic en el catálogo")
    @PostMapping
    public ResponseEntity<FanfictionResponseDTO> saveFanfic(@RequestBody FanfictionResponseDTO dto) {
        // Asumimos que el servicio tiene un método para manejar esto.
        return ResponseEntity.ok(service.saveFromDTO(dto));
    }

    /**
     * Updates an existing fanfiction in the local catalog.
     *
     * @param id  the unique identifier of the fanfiction to update
     * @param dto the payload containing updated fanfiction details
     * @return a {@link ResponseEntity} containing the updated {@link FanfictionResponseDTO},
     *         or 404 Not Found if the fanfiction does not exist.
     */
    @Operation(summary = "Actualizar un fanfic existente")
    @PutMapping("/{id}")
    public ResponseEntity<FanfictionResponseDTO> updateFanfic(@PathVariable Long id, @RequestBody FanfictionResponseDTO dto) {
        return service.updateFanfic(id, dto)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
