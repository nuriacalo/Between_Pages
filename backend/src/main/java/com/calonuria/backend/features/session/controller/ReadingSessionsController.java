package com.calonuria.backend.features.session.controller;

import com.calonuria.backend.features.session.dto.ReadingSessionRecordDTO;
import com.calonuria.backend.features.session.dto.ReadingSessionStatsDTO;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.features.session.service.ReadingSessionService;
import com.calonuria.backend.features.user.service.GamificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller that handles HTTP requests for reading sessions.
 * Provides endpoints to record completed reading sessions and fetch reading velocity statistics
 * (pages per hour) for predicting reading completion times.
 * 
 * <p>Base path: {@code /api/reading-sessions}</p>
 */
@RestController
@RequestMapping("/api/reading-sessions")
@RequiredArgsConstructor
@Tag(name = "Reading Sessions", description = "Sesiones temporizadas y predicción de tiempo")
public class ReadingSessionsController {

    private final ReadingSessionService readingSessionService;
    private final UserRepository userRepository;
    private final GamificationService gamificationService;

    /**
     * Saves a reading session upon completion of the reading timer.
     * Maps the session to a book, manga, or fanfic and updates gamification activity.
     *
     * @param userDetails the authenticated user context
     * @param dto         the payload containing the session data (duration, pages read, item ID)
     * @return a {@link ResponseEntity} indicating success, or throws an error if user is not found.
     */
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

    /**
     * Retrieves reading statistics and ETA calculations based on the user's historical reading velocity.
     *
     * @param userDetails    the authenticated user context
     * @param remainingPages the number of pages/chapters remaining in the current media
     * @param bookId         (Optional) ID of the book being read
     * @param mangaId        (Optional) ID of the manga being read
     * @param fanficId       (Optional) ID of the fanfic being read
     * @return a {@link ResponseEntity} containing a {@link ReadingSessionStatsDTO} with the
     *         average speed and estimated seconds to finish the remaining pages.
     */
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
