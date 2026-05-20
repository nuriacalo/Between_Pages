package com.calonuria.backend.features.list.controller;

import com.calonuria.backend.features.list.dto.AddContentToListRequestDTO;
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

/**
 * REST Controller for managing user reading lists (custom collections).
 * Allows users to create, view, and delete their customized lists.
 * 
 * <p>Base path: {@code /api/lists}</p>
 */
@RestController
@RequestMapping("/api/lists")
@RequiredArgsConstructor
@Tag(name = "Reading Lists", description = "Gestión de colecciones y listas personalizadas del usuario")
public class ReadingListController {

    private final ReadingListService readingListService;

    /**
     * Retrieves all custom reading lists owned by a specific user.
     *
     * @param userId the unique identifier of the user
     * @return a {@link ResponseEntity} containing a list of {@link ReadingListDTO}
     */
    @Operation(summary = "Obtener las listas de un usuario", description = "Devuelve todas las carpetas/colecciones creadas por un usuario específico.")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ReadingListDTO>> getUserLists(@PathVariable Long userId) {
        return ResponseEntity.ok(readingListService.getUserLists(userId));
    }

    /**
     * Creates a new custom reading list for a specific user.
     *
     * @param userId     the unique identifier of the user who will own the list
     * @param requestDTO the payload containing the list name and optional description
     * @return a {@link ResponseEntity} containing the newly created {@link ReadingListDTO} with status 201 Created
     */
    @Operation(summary = "Crear nueva lista", description = "Crea una nueva colección personalizada (ej. 'Favoritos') para el usuario.")
    @PostMapping("/user/{userId}")
    public ResponseEntity<ReadingListDTO> createList(
            @PathVariable Long userId,
            @Valid @RequestBody ReadingListRequestDTO requestDTO) {
        return new ResponseEntity<>(readingListService.createList(userId, requestDTO), HttpStatus.CREATED);
    }

    /**
     * Permanently deletes a reading list and removes all its item associations.
     * Note: This does not delete the actual catalog items (books, mangas, fanfics).
     *
     * @param listId the unique identifier of the list to delete
     * @return a {@link ResponseEntity} with status 204 No Content
     */
    @Operation(summary = "Eliminar una lista", description = "Elimina permanentemente una colección y remueve todos los elementos que contenga (sin borrar las obras del catálogo).")
    @DeleteMapping("/{listId}")
    public ResponseEntity<Void> deleteList(@PathVariable Long listId) {
        readingListService.deleteList(listId);
        return ResponseEntity.noContent().build();
    }

    /**
     * Adds a new item (book, manga, or fanfic) to a reading list.
     *
     * @param listId     the unique identifier of the list
     * @param requestDTO the payload containing the content ID and type
     * @return a {@link ResponseEntity} with status 201 Created
     */
    @Operation(summary = "Añadir contenido a una lista", description = "Añade un nuevo elemento (libro, manga o fanfic) a una lista de lectura.")
    @PostMapping("/{listId}/content")
    public ResponseEntity<Void> addContentToList(
            @PathVariable Long listId,
            @Valid @RequestBody AddContentToListRequestDTO requestDTO) {
        readingListService.addContentToList(listId, requestDTO);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    /**
     * Retrieves a reading list detail including its items.
     *
     * @param listId the unique identifier of the list
     * @return a {@link ResponseEntity} containing the detailed list.
     */
    @Operation(summary = "Obtener detalle de una lista", description = "Devuelve la lista con sus elementos (ordenados por posición).")
    @GetMapping("/{listId}")
    public ResponseEntity<com.calonuria.backend.features.list.dto.ReadingListDetailResponseDTO> getListDetail(
            @PathVariable Long listId) {
        return ResponseEntity.ok(readingListService.getListDetail(listId));
    }
}
