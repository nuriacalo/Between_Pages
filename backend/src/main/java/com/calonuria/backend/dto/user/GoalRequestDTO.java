package com.calonuria.backend.dto.user;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class GoalRequestDTO {
    @NotNull
    private Integer goalYear;

    @NotNull
    @Min(1)
    private Integer targetAmount;
}
