package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.repository.ReadingGoalRepository;
import org.springframework.stereotype.Service;

import java.time.Year;
import java.util.Map;

@Service
public class ProfileService {

    private final ReadingGoalRepository readingGoalRepository;

    public ProfileService(ReadingGoalRepository readingGoalRepository) {
        this.readingGoalRepository = readingGoalRepository;
    }

    public Map<String, Integer> getAnnualGoal(Long userId) {
        int year = Year.now().getValue();
        ReadingGoal goal = readingGoalRepository.findByUserIdAndGoalYear(userId, year)
                .orElse(new ReadingGoal(userId, year, 0));
        
        // This is a placeholder. The actual number of completed books should be calculated.
        int completed = 0; 

        return Map.of("target", goal.getTargetAmount(), "completed", completed);
    }

    public void setAnnualGoal(Long userId, int target) {
        int year = Year.now().getValue();
        ReadingGoal goal = readingGoalRepository.findByUserIdAndGoalYear(userId, year)
                .orElse(new ReadingGoal(userId, year, 0));
        goal.setTargetAmount(target);
        readingGoalRepository.save(goal);
    }
}