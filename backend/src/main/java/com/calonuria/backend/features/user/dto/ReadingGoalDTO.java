package com.calonuria.backend.features.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para la meta de lectura anual del usuario.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReadingGoalDTO {

    private Long id;
    private Integer goalYear;
    private Integer targetAmount;
}
