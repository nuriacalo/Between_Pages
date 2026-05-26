package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.dto.ReadingGoalDTO;
import com.calonuria.backend.features.user.dto.ReadingStreakDTO;
import com.calonuria.backend.features.user.dto.ReadingActivityRequestDTO; // Import added
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.features.user.service.ReadingStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.Map;

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
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado: " + email));
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
            Principal principal) {
        return ResponseEntity.ok(readingStatsService.getOrCreateReadingGoal(
                getUserByEmail(principal.getName()).getId()));
    }

    /**
     * Updates or sets the target reading goal amount for the current year.
     *
     * @param email        the authenticated user's email
     * @param payload a map containing the "targetAmount"
     * @return a {@link ResponseEntity} containing the updated {@link ReadingGoalDTO}
     */
    @Operation(summary = "Actualizar o establecer meta de lectura")
    @PostMapping("/goal")
    public ResponseEntity<ReadingGoalDTO> updateReadingGoal(
            Principal principal,
            @RequestBody Map<String, Integer> payload) {
        Integer targetAmount = payload.get("targetAmount");
        if (targetAmount == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(readingStatsService.updateReadingGoal(
                getUserByEmail(principal.getName()).getId(), targetAmount));
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
            Principal principal,
            @RequestParam(name = "localDate", required = false) String localDateString) {
        LocalDate referenceDate = localDateString != null 
                ? LocalDate.parse(localDateString) 
                : LocalDate.now();
        return ResponseEntity.ok(readingStatsService.calculateReadingStreak(
                getUserByEmail(principal.getName()).getId(), referenceDate));
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
            Principal principal,
            @RequestBody ReadingActivityRequestDTO request) { // Modified to accept DTO
        readingStatsService.recordActivity(getUserByEmail(principal.getName()).getId(), request.getLocalDate()); // Modified to pass localDate
        return ResponseEntity.ok().build();
    }

    /**
     * Calcula y devuelve las estadísticas de lectura para un item específico.
     *
     * @param principal el usuario autenticado
     * @param itemId el ID del libro
     * @return un {@link ResponseEntity} con el mapa de estadísticas
     */
    @Operation(summary = "Obtener estadísticas de lectura para un item")
    @GetMapping("/item/{itemId}")
    public ResponseEntity<Map<String, Object>> getItemReadingStats(
            Principal principal,
            @PathVariable Long itemId,
            @RequestParam(name = "type", required = true) String type) {
        User user = getUserByEmail(principal.getName());
        Map<String, Object> stats = readingStatsService.getItemReadingStats(user.getId(), itemId, type.toUpperCase());
        return ResponseEntity.ok(stats);
    }
}
