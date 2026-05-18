package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.dto.ReadingGoalDTO;
import com.calonuria.backend.features.user.dto.ReadingStreakDTO;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.features.user.service.ReadingStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller for managing detailed reading statistics.
 * This controller handles logic for reading goals, consecutive reading streaks,
 * and recording daily activity points.
 * 
 * <p>Base path: {@code /api/reading-stats}</p>
 */
@RestController
@RequestMapping("/api/reading-stats")
@Tag(name = "Estadísticas de Lectura", description = "Endpoints para meta anual y racha de lectura")
@SecurityRequirement(name = "bearerAuth")
@RequiredArgsConstructor
public class ReadingStatsController {

    private final ReadingStatsService readingStatsService;
    private final UserRepository userRepository;

    /**
     * Internal helper method to resolve the authenticated user's ID from their email.
     *
     * @param email the user's email extracted from the JWT token
     * @return the resolved {@link User} entity
     * @throws RuntimeException if the user cannot be found in the database
     */
    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }

    /**
     * Retrieves the reading goal for the current year.
     * If a goal does not exist yet, a default goal of 12 items is automatically created.
     *
     * @param email the authenticated user's email
     * @return a {@link ResponseEntity} containing a {@link ReadingGoalDTO}
     */
    @Operation(summary = "Obtener meta de lectura anual")
    @GetMapping("/goal")
    public ResponseEntity<ReadingGoalDTO> getReadingGoal(
            @AuthenticationPrincipal String email) {
        return ResponseEntity.ok(readingStatsService.getOrCreateReadingGoal(
                getUserByEmail(email).getId()));
    }

    /**
     * Updates the target reading goal amount for the current year.
     *
     * @param email        the authenticated user's email
     * @param targetAmount the new target number of items to read
     * @return a {@link ResponseEntity} containing the updated {@link ReadingGoalDTO}
     */
    @Operation(summary = "Actualizar meta de lectura")
    @PutMapping("/goal")
    public ResponseEntity<ReadingGoalDTO> updateReadingGoal(
            @AuthenticationPrincipal String email,
            @RequestParam Integer targetAmount) {
        return ResponseEntity.ok(readingStatsService.updateReadingGoal(
                getUserByEmail(email).getId(), targetAmount));
    }

    /**
     * Calculates and returns the user's current reading streak and their daily
     * activity over the last 7 days.
     *
     * @param email the authenticated user's email
     * @return a {@link ResponseEntity} containing a {@link ReadingStreakDTO}
     */
    @Operation(summary = "Obtener racha de lectura y actividad semanal")
    @GetMapping("/streak")
    public ResponseEntity<ReadingStreakDTO> getReadingStreak(
            @AuthenticationPrincipal String email) {
        return ResponseEntity.ok(readingStatsService.calculateReadingStreak(
                getUserByEmail(email).getId()));
    }

    /**
     * Forces a record of reading activity for today.
     * Usually called silently when a user updates progress on any journal item.
     *
     * @param email the authenticated user's email
     * @return a {@link ResponseEntity} with status 200 OK
     */
    @Operation(summary = "Registrar actividad de lectura de hoy")
    @PostMapping("/activity")
    public ResponseEntity<Void> recordActivity(
            @AuthenticationPrincipal String email) {
        readingStatsService.recordActivity(getUserByEmail(email).getId());
        return ResponseEntity.ok().build();
    }
}
