package com.calonuria.backend.dto.user;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.util.List;

/**
 * DTO para devolver la información de la racha de lectura del usuario.
 */
@Data
@Schema(description = "Datos de la racha de lectura y actividad semanal del usuario")
public class StreakResponseDTO {
    
    @Schema(description = "Días consecutivos que el usuario lleva leyendo", example = "5")
    private int currentStreak;
    
    @Schema(description = "Lista de 7 booleanos (Lunes a Domingo) indicando si hubo actividad de lectura en la semana actual", 
            example = "[true, true, false, false, false, false, false]")
    private List<Boolean> weeklyActivity;
}