package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.BookJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.BookJournalResponseDTO;
import com.calonuria.backend.service.journal.BookJournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del diario de lectura de libros.
 */
@RestController
@RequestMapping("/api/book-journal")
@Tag(name = "Book Journal", description = "Seguimiento de lectura de libros")
public class BookJournalController {

    @Autowired
    private BookJournalService bookJournalService;

    @Operation(summary = "Guardar o actualizar progreso de un libro")
    @PostMapping
    public ResponseEntity<BookJournalResponseDTO> saveProgress(
            @Valid @RequestBody BookJournalRegistrationDTO dto) {
        return ResponseEntity.ok(bookJournalService.saveProgress(dto));
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<BookJournalResponseDTO>> getJournal(
            @PathVariable Long userId) {
        return ResponseEntity.ok(bookJournalService.getUserJournal(userId));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/user/{userId}/status")
    public ResponseEntity<List<BookJournalResponseDTO>> getByStatus(
            @PathVariable Long userId,
            @RequestParam String status) {
        return ResponseEntity.ok(bookJournalService.getByStatus(userId, status));
    }

    @Operation(summary = "Obtener relecturas del usuario")
    @GetMapping("/user/{userId}/rereadings")
    public ResponseEntity<List<BookJournalResponseDTO>> getRereadings(
            @PathVariable Long userId) {
        return ResponseEntity.ok(bookJournalService.getRereadings(userId));
    }

    @Operation(summary = "Eliminar un registro de journal")
    @DeleteMapping("/{journalId}")
    public ResponseEntity<?> deleteJournal(@PathVariable Long journalId) {
        bookJournalService.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}
