package com.calonuria.backend.controller.user;

import com.calonuria.backend.dto.user.StreakResponseDTO;
import com.calonuria.backend.service.user.UserStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * DEPRECATED: Use ReadingStatsController instead.
 * Este controlador ha sido consolidado en ReadingStatsController para evitar duplicación.
 * El endpoint `/api/users/streak` ha sido migrado a `/api/reading-stats/streak`.
 * Esta clase se mantiene solo para compatibilidad histórica.
 */
@Deprecated
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "User Stats (DEPRECATED)", description = "DEPRECATED: Use /api/reading-stats endpoints instead")
public class UserStatsController {

    private final UserStatsService userStatsService;

    /**
     * DEPRECATED: Use ReadingStatsController.getReadingStreak() instead.
     * Obtiene la racha actual de lectura del usuario autenticado.
     * @param authentication Token JWT del usuario inyectado por Spring Security.
     * @deprecated Migrado a ReadingStatsController en /api/reading-stats/streak
     */
    @Deprecated
    @Operation(summary = "Obtener racha (DEPRECATED)", description = "DEPRECATED: Use /api/reading-stats/streak instead")
    @GetMapping("/streak")
    public ResponseEntity<StreakResponseDTO> getUserStreak(Authentication authentication) {
        String email = authentication.getName(); // Extrae el email del token JWT
        return ResponseEntity.ok(userStatsService.getUserStreak(email));
    }
}