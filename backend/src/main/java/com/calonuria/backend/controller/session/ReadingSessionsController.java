package com.calonuria.backend.controller.session;

import com.calonuria.backend.dto.session.ReadingSessionRecordDTO;
import com.calonuria.backend.dto.session.ReadingSessionStatsDTO;
import com.calonuria.backend.model.session.ReadingSession.ItemType;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.session.ReadingSessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Controller para sesiones de lectura (timer).
 * POST save session data, GET stats for ETA prediction.
 */
@RestController
@RequestMapping("/api/reading-sessions")
@RequiredArgsConstructor
@Tag(name = "Reading Sessions", description = "Sesiones temporizadas y predicción de tiempo")
public class ReadingSessionsController {

    private final ReadingSessionService readingSessionService;
    private final UserRepository userRepository;

    @Operation(summary = "Guardar sesión de lectura (finalizar timer)")
    @PostMapping
    public ResponseEntity<Void> saveSession(@Valid @RequestBody ReadingSessionRecordDTO dto) {
        readingSessionService.saveSession(dto);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Estadísticas de velocidad y ETA para tiempo restante")
    @GetMapping("/stats")
    public ResponseEntity<ReadingSessionStatsDTO> getStats(
            @AuthenticationPrincipal String email,
            @RequestParam @Valid int remainingPages,
            @RequestParam(required = false) Long bookId,
            @RequestParam(required = false) Long mangaId,
            @RequestParam(required = false) Long fanficId) {
        
        var user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        ItemType itemType = null;
        Long itemId = null;

        if (bookId != null) {
            itemType = ItemType.BOOK;
            itemId = bookId;
        } else if (mangaId != null) {
            itemType = ItemType.MANGA;
            itemId = mangaId;
        } else if (fanficId != null) {
            itemType = ItemType.FANFIC;
            itemId = fanficId;
        }

        var stats = readingSessionService.getReadingStats(user.getId(), itemType, itemId, remainingPages);
        return ResponseEntity.ok(stats);
    }
}

