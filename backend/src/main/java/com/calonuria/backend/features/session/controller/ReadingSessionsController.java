package com.calonuria.backend.controller.session;

import com.calonuria.backend.dto.session.ReadingSessionRecordDTO;
import com.calonuria.backend.dto.session.ReadingSessionStatsDTO;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.session.ReadingSessionService;
import com.calonuria.backend.service.user.GamificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

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
    private final GamificationService gamificationService;

    @Operation(summary = "Guardar sesión de lectura (finalizar timer)")
    @PostMapping
    public ResponseEntity<Void> saveSession(@AuthenticationPrincipal UserDetails userDetails,
                                           @Valid @RequestBody ReadingSessionRecordDTO dto) {
        var user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        dto.setUserId(user.getId());
        readingSessionService.saveSession(dto);
        gamificationService.recordActivity(userDetails.getUsername());
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Estadísticas de velocidad y ETA para tiempo restante")
    @GetMapping("/stats")
    public ResponseEntity<ReadingSessionStatsDTO> getStats(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam @Valid int remainingPages,
            @RequestParam(required = false) Long bookId,
            @RequestParam(required = false) Long mangaId,
            @RequestParam(required = false) Long fanficId) {
        
        var user = userRepository.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        var stats = readingSessionService.getReadingStats(user.getId(), bookId, mangaId, fanficId, remainingPages);
        return ResponseEntity.ok(stats);
    }
}
