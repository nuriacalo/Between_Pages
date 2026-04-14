package com.calonuria.backend.controller.list;

import com.calonuria.backend.dto.list.ReadingListDetailResponseDTO;
import com.calonuria.backend.dto.list.ReadingListRegistrationDTO;
import com.calonuria.backend.dto.list.ReadingListResponseDTO;
import com.calonuria.backend.service.list.ReadingListService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión de listas de lectura.
 */
@RestController
@RequestMapping("/api/reading-list")
@Tag(name = "Reading Lists", description = "Gestión de listas personalizadas del usuario")
public class ReadingListController {

    @Autowired
    private ReadingListService readingListService;

    @Operation(summary = "Crear una nueva lista")
    @PostMapping
    public ResponseEntity<ReadingListResponseDTO> createList(@Valid @RequestBody ReadingListRegistrationDTO dto) {
        return ResponseEntity.ok(readingListService.createList(dto));
    }

    @Operation(summary = "Obtener todas las listas de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ReadingListResponseDTO>> getUserLists(
            @PathVariable Long userId) {
        return ResponseEntity.ok(readingListService.getUserLists(userId));
    }

    @Operation(summary = "Eliminar una lista")
    @DeleteMapping("/{listId}")
    public ResponseEntity<?> deleteList(@PathVariable Long listId) {
        readingListService.deleteList(listId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReadingListDetailResponseDTO> getDetail(
            @PathVariable Long id) {
        return ResponseEntity.ok(readingListService.getListDetail(id));
    }

    @Operation(summary = "Actualizar una lista")
    @PutMapping("/{listId}")
    public ResponseEntity<ReadingListResponseDTO> updateList(
            @PathVariable Long listId,
            @Valid @RequestBody ReadingListRegistrationDTO dto) {
        return ResponseEntity.ok(readingListService.updateList(listId, dto));
    }

    @Operation(summary = "Añadir item a una lista")
    @PostMapping("/{listId}/items")
    public ResponseEntity<?> addItem(
            @PathVariable Long listId,
            @RequestParam String type,
            @RequestParam Long itemId) {
        readingListService.addItem(listId, type, itemId);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Eliminar item de una lista")
    @DeleteMapping("/{listId}/items")
    public ResponseEntity<?> removeItem(
            @PathVariable Long listId,
            @RequestParam String type,
            @RequestParam Long itemId) {
        readingListService.removeItem(listId, type, itemId);
        return ResponseEntity.ok().build();
    }
}
