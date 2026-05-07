package com.calonuria.backend.dto.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GamificationStatsDTO {
    private Integer annualGoal;
    private Integer currentStreak;
    private List<Boolean> weekActivity;
}
