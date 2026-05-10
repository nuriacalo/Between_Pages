package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.user.dto.GamificationStatsDTO;
import com.calonuria.backend.features.user.dto.GoalRequestDTO;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.features.user.model.ReadingActivity;
import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.ReadingActivityRepository;
import com.calonuria.backend.features.user.repository.ReadingGoalRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.features.user.application.events.ReadingActivityEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Slf4j
public class GamificationService {

    private final UserRepository userRepository;
    private final ReadingActivityRepository readingActivityRepository;
    private final ReadingGoalRepository readingGoalRepository;

    public GamificationService(UserRepository userRepository,
                               ReadingActivityRepository readingActivityRepository,
                               ReadingGoalRepository readingGoalRepository) {
        this.userRepository = userRepository;
        this.readingActivityRepository = readingActivityRepository;
        this.readingGoalRepository = readingGoalRepository;
    }

    @EventListener
    @Transactional
    public void handleReadingActivity(ReadingActivityEvent event) {
        log.info("Received reading activity event for user: {}", event.getUsername());
        recordActivity(event.getUsername());
    }

    @Transactional(readOnly = true)
    public GamificationStatsDTO getStats(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con email: " + email));

        int currentYear = LocalDate.now().getYear();
        
        Optional<ReadingGoal> goalOpt = readingGoalRepository.findByUserAndGoalYear(user, currentYear);
        int annualGoal = goalOpt.map(ReadingGoal::getTargetAmount).orElse(12);

        List<LocalDate> activityDates = readingActivityRepository.findActivityDatesByUserId(user.getId());
        int currentStreak = calculateStreak(activityDates);

        List<Boolean> weekActivity = new ArrayList<>();
        LocalDate today = LocalDate.now();
        
        for (int i = 6; i >= 0; i--) {
            LocalDate targetDate = today.minusDays(i);
            weekActivity.add(activityDates.contains(targetDate));
        }

        return new GamificationStatsDTO(annualGoal, currentStreak, weekActivity);
    }

    @Transactional
    public void updateGoal(String email, GoalRequestDTO dto) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con email: " + email));

        Optional<ReadingGoal> goalOpt = readingGoalRepository.findByUserAndGoalYear(user, dto.getGoalYear());
        
        ReadingGoal goal;
        if (goalOpt.isPresent()) {
            goal = goalOpt.get();
            goal.setTargetAmount(dto.getTargetAmount());
        } else {
            goal = new ReadingGoal();
            goal.setUser(user);
            goal.setGoalYear(dto.getGoalYear());
            goal.setTargetAmount(dto.getTargetAmount());
        }
        
        readingGoalRepository.save(goal);
    }
    
    public void recordActivity(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
                
        LocalDate today = LocalDate.now();
        if (!readingActivityRepository.existsByUserIdAndActivityDate(user.getId(), today)) {
            ReadingActivity activity = new ReadingActivity();
            activity.setUser(user);
            activity.setActivityDate(today);
            readingActivityRepository.save(activity);
        }
    }

    private int calculateStreak(List<LocalDate> sortedDates) {
        if (sortedDates == null || sortedDates.isEmpty()) {
            return 0;
        }

        LocalDate currentDate = LocalDate.now();
        int streak = 0;
        LocalDate expectedDate;

        if (sortedDates.get(0).equals(currentDate)) {
            streak = 1;
            expectedDate = currentDate.minusDays(1);
        } else if (sortedDates.get(0).equals(currentDate.minusDays(1))) {
            streak = 1;
            expectedDate = currentDate.minusDays(2);
        } else {
            return 0;
        }

        for (int i = 1; i < sortedDates.size(); i++) {
            if (sortedDates.get(i).equals(expectedDate)) {
                streak++;
                expectedDate = expectedDate.minusDays(1);
            } else {
                break;
            }
        }

        return streak;
    }
}
