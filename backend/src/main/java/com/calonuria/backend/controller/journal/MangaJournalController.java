package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.MangaJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.MangaJournalResponseDTO;
import com.calonuria.backend.service.journal.MangaJournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del diario de lectura de mangas.
 */
@RestController
@RequestMapping("/api/manga-journal")
@Tag(name = "Manga Journal", description = "Seguimiento de lectura de mangas")
public class MangaJournalController {

    @Autowired
    private MangaJournalService mangaJournalService;

    @Operation(summary = "Guardar o actualizar progreso de un manga")
    @PostMapping
    public ResponseEntity<MangaJournalResponseDTO> saveProgress(
            @Valid @RequestBody MangaJournalRegistrationDTO dto) {
        return ResponseEntity.ok(mangaJournalService.saveProgress(dto));
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<MangaJournalResponseDTO>> getJournal(
            @PathVariable Long userId) {
        return ResponseEntity.ok(mangaJournalService.getUserJournal(userId));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/user/{userId}/status")
    public ResponseEntity<List<MangaJournalResponseDTO>> getByStatus(
            @PathVariable Long userId,
            @RequestParam String status) {
        return ResponseEntity.ok(mangaJournalService.getByStatus(userId, status));
    }

    @Operation(summary = "Obtener relecturas del usuario")
    @GetMapping("/user/{userId}/rereadings")
    public ResponseEntity<List<MangaJournalResponseDTO>> getRereadings(
            @PathVariable Long userId) {
        return ResponseEntity.ok(mangaJournalService.getRereadings(userId));
    }

    @Operation(summary = "Eliminar un registro de journal")
    @DeleteMapping("/{journalId}")
    public ResponseEntity<?> deleteJournal(@PathVariable Long journalId) {
        mangaJournalService.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}
