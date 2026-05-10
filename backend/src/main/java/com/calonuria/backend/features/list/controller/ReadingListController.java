package com.calonuria.backend.features.list.controller;

import com.calonuria.backend.features.list.dto.ReadingListDTO;
import com.calonuria.backend.features.list.dto.ReadingListRequestDTO;
import com.calonuria.backend.features.list.service.ReadingListService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/lists")
@RequiredArgsConstructor
@Tag(name = "Reading Lists", description = "Gestión de colecciones y listas personalizadas del usuario")
public class ReadingListController {

    private final ReadingListService readingListService;

    @Operation(summary = "Obtener las listas de un usuario", description = "Devuelve todas las carpetas/colecciones creadas por un usuario específico.")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ReadingListDTO>> getUserLists(@PathVariable Long userId) {
        return ResponseEntity.ok(readingListService.getUserLists(userId));
    }

    @Operation(summary = "Crear nueva lista", description = "Crea una nueva colección personalizada (ej. 'Favoritos') para el usuario.")
    @PostMapping("/user/{userId}")
    public ResponseEntity<ReadingListDTO> createList(
            @PathVariable Long userId,
            @Valid @RequestBody ReadingListRequestDTO requestDTO) {
        return new ResponseEntity<>(readingListService.createList(userId, requestDTO), HttpStatus.CREATED);
    }

    @Operation(summary = "Eliminar una lista", description = "Elimina permanentemente una colección y remueve todos los elementos que contenga (sin borrar las obras del catálogo).")
    @DeleteMapping("/{listId}")
    public ResponseEntity<Void> deleteList(@PathVariable Long listId) {
        readingListService.deleteList(listId);
        return ResponseEntity.noContent().build();
    }
}