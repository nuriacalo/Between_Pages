package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.FanficJournalRegistrationDTO;
import com.calonuria.backend.dto.journal.FanficJournalResponseDTO;
import com.calonuria.backend.service.journal.FanficJournalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * Controlador para la gestión del diario de lectura de fanfictions.
 */
@RestController
@RequestMapping("/api/fanfic-journal")
@Tag(name = "Fanfic Journal", description = "Seguimiento de lectura de fanfictions")
public class FanficJournalController {

    @Autowired
    private FanficJournalService fanficJournalService;

    @Operation(summary = "Guardar o actualizar progreso de un fanfic")
    @PostMapping
    public ResponseEntity<FanficJournalResponseDTO> saveProgress(
            @Valid @RequestBody FanficJournalRegistrationDTO dto) {
        return ResponseEntity.ok(fanficJournalService.saveProgress(dto));
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<FanficJournalResponseDTO>> getJournal(
            @PathVariable Long userId) {
        return ResponseEntity.ok(fanficJournalService.getUserJournal(userId));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/user/{userId}/status")
    public ResponseEntity<List<FanficJournalResponseDTO>> getByStatus(
            @PathVariable Long userId,
            @RequestParam String status) {
        return ResponseEntity.ok(fanficJournalService.getByStatus(userId, status));
    }

    @Operation(summary = "Obtener relecturas del usuario")
    @GetMapping("/user/{userId}/rereadings")
    public ResponseEntity<List<FanficJournalResponseDTO>> getRereadings(
            @PathVariable Long userId) {
        return ResponseEntity.ok(fanficJournalService.getRereadings(userId));
    }

    @Operation(summary = "Eliminar un registro de journal")
    @DeleteMapping("/{journalId}")
    public ResponseEntity<?> deleteJournal(@PathVariable Long journalId) {
        fanficJournalService.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}