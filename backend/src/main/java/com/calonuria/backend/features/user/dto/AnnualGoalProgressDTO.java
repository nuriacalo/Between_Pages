package com.calonuria.backend.features.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AnnualGoalProgressDTO {
    private int year;
    private int targetAmount;
    private int finishedCount;
}