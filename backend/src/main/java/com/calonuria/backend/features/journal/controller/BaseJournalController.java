package com.calonuria.backend.controller.journal;

import com.calonuria.backend.dto.journal.BaseJournalRegistrationDTO;
import com.calonuria.backend.service.journal.BaseJournalService;
import com.calonuria.backend.service.user.event.ReadingActivityEvent;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
public abstract class BaseJournalController<
        D, // Response DTO
        R extends BaseJournalRegistrationDTO, // Registration DTO
        S extends BaseJournalService<?, D, R>> { // The specific Journal Service

    private final S journalService;
    private final ApplicationEventPublisher eventPublisher;

    protected BaseJournalController(S journalService, ApplicationEventPublisher eventPublisher) {
        this.journalService = journalService;
        this.eventPublisher = eventPublisher;
    }

    @Operation(summary = "Guardar o actualizar progreso de una obra")
    @PutMapping
    public ResponseEntity<D> saveProgress(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody R dto) {
        log.info("[BaseJournalController] saveProgress called for user {}", userDetails.getUsername());
        D response = journalService.saveProgress(dto);
        eventPublisher.publishEvent(new ReadingActivityEvent(this, userDetails.getUsername()));
        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Obtener todos los journals de un usuario")
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<D>> getJournal(@PathVariable Long userId) {
        return ResponseEntity.ok(journalService.getUserJournal(userId));
    }

    @Operation(summary = "Obtener journals por estado")
    @GetMapping("/user/{userId}/status")
    public ResponseEntity<List<D>> getByStatus(
            @PathVariable Long userId,
            @RequestParam String status) {
        return ResponseEntity.ok(journalService.getByStatus(userId, status));
    }

    @Operation(summary = "Obtener relecturas del usuario")
    @GetMapping("/user/{userId}/rereadings")
    public ResponseEntity<List<D>> getRereadings(@PathVariable Long userId) {
        return ResponseEntity.ok(journalService.getRereadings(userId));
    }

    @Operation(summary = "Eliminar un registro de journal")
    @DeleteMapping("/{journalId}")
    public ResponseEntity<?> deleteJournal(@PathVariable Long journalId) {
        journalService.deleteJournal(journalId);
        return ResponseEntity.noContent().build();
    }
}
