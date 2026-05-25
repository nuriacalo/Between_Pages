package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.dto.GamificationStatsDTO;
import com.calonuria.backend.features.user.dto.GoalRequestDTO;
import com.calonuria.backend.features.user.service.ReadingStatsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/gamification")
@Tag(name = "Gamification", description = "Endpoints para la gamificación (metas y rachas)")
public class GamificationController {

    private final ReadingStatsService readingStatsService;

    public GamificationController(ReadingStatsService readingStatsService) {
        this.readingStatsService = readingStatsService;
    }

    @Operation(summary = "Obtener estadísticas de gamificación del usuario actual")
    @GetMapping("/stats")
    public ResponseEntity<GamificationStatsDTO> getStats(@AuthenticationPrincipal UserDetails userDetails) {
        GamificationStatsDTO stats = readingStatsService.getStats(userDetails.getUsername());
        return ResponseEntity.ok(stats);
    }

    @Operation(summary = "Actualizar la meta anual del usuario actual")
    @PostMapping("/goal")
    public ResponseEntity<Void> updateGoal(@AuthenticationPrincipal UserDetails userDetails,
                                           @Valid @RequestBody GoalRequestDTO dto) {
        readingStatsService.updateGoal(userDetails.getUsername(), dto);
        return ResponseEntity.ok().build();
    }
}