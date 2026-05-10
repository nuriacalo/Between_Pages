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
 * Controlador para estadísticas de lectura del usuario.
 * Gestiona meta anual y racha de lectura.
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
     * Obtiene el usuario por email o lanza excepción.
     * Método privado para evitar duplicación de código.
     */
    private User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }

    /**
     * Obtiene la meta de lectura del usuario para el año actual.
     * Si no existe, crea una meta por defecto de 12 libros.
     */
    @Operation(summary = "Obtener meta de lectura anual")
    @GetMapping("/goal")
    public ResponseEntity<ReadingGoalDTO> getReadingGoal(
            @AuthenticationPrincipal String email) {
        return ResponseEntity.ok(readingStatsService.getOrCreateReadingGoal(
                getUserByEmail(email).getId()));
    }

    /**
     * Actualiza la meta de lectura del usuario.
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
     * Obtiene la racha de lectura y actividad semanal del usuario.
     */
    @Operation(summary = "Obtener racha de lectura y actividad semanal")
    @GetMapping("/streak")
    public ResponseEntity<ReadingStreakDTO> getReadingStreak(
            @AuthenticationPrincipal String email) {
        return ResponseEntity.ok(readingStatsService.calculateReadingStreak(
                getUserByEmail(email).getId()));
    }

    /**
     * Registra actividad de lectura para hoy (llamar cuando se actualiza progreso).
     */
    @Operation(summary = "Registrar actividad de lectura de hoy")
    @PostMapping("/activity")
    public ResponseEntity<Void> recordActivity(
            @AuthenticationPrincipal String email) {
        readingStatsService.recordActivity(getUserByEmail(email).getId());
        return ResponseEntity.ok().build();
    }
}
