package com.calonuria.backend.dto.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * DTO para la racha de lectura y actividad semanal del usuario.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReadingStreakDTO {

    private Integer currentStreak;
    private List<Boolean> weekActivity; // 7 días, true si hubo actividad ese día
    private Long totalActiveDays;
}
