package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.session.repository.ReadingSessionRepository;
import com.calonuria.backend.features.user.dto.AnnualGoalProgressDTO;
import com.calonuria.backend.features.user.dto.GamificationStatsDTO;
import com.calonuria.backend.features.user.dto.GoalRequestDTO;
import com.calonuria.backend.features.user.dto.ReadingGoalDTO;
import com.calonuria.backend.features.user.dto.ReadingStreakDTO;
import com.calonuria.backend.features.user.model.ReadingActivity;
import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.ReadingActivityRepository;
import com.calonuria.backend.features.user.repository.ReadingGoalRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.Year;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReadingStatsService {

    private final ReadingGoalRepository readingGoalRepository;
    private final ReadingActivityRepository readingActivityRepository;
    private final UserRepository userRepository;
    private final ReadingSessionRepository readingSessionRepository;

    @Transactional
    public ReadingGoalDTO getOrCreateReadingGoal(Long userId) {
        int currentYear = LocalDate.now().getYear();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Optional<ReadingGoal> existingGoal = readingGoalRepository.findByUserAndGoalYear(user, currentYear);

        if (existingGoal.isPresent()) {
            ReadingGoal goal = existingGoal.get();
            return new ReadingGoalDTO(goal.getId(), goal.getGoalYear(), goal.getTargetAmount());
        }

        ReadingGoal newGoal = new ReadingGoal();
        newGoal.setUser(user);
        newGoal.setGoalYear(currentYear);
        newGoal.setTargetAmount(12);
        
        try {
            ReadingGoal saved = readingGoalRepository.save(newGoal);
            return new ReadingGoalDTO(saved.getId(), saved.getGoalYear(), saved.getTargetAmount());
        } catch (DataIntegrityViolationException e) {
            log.warn("Reading goal for year {} already exists for user ID {}", currentYear, userId);
            ReadingGoal goal = readingGoalRepository.findByUserAndGoalYear(user, currentYear)
                    .orElseThrow(() -> new RuntimeException("Unexpected error fetching reading goal"));
            return new ReadingGoalDTO(goal.getId(), goal.getGoalYear(), goal.getTargetAmount());
        }
    }

    @Transactional
    public ReadingGoalDTO updateReadingGoal(Long userId, Integer targetAmount) {
        int currentYear = LocalDate.now().getYear();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        ReadingGoal goal = readingGoalRepository.findByUserAndGoalYear(user, currentYear)
                .orElseGet(() -> {
                    ReadingGoal newGoal = new ReadingGoal();
                    newGoal.setUser(user);
                    newGoal.setGoalYear(currentYear);
                    return newGoal;
                });

        goal.setTargetAmount(targetAmount);
        try {
            ReadingGoal saved = readingGoalRepository.save(goal);
            return new ReadingGoalDTO(saved.getId(), saved.getGoalYear(), saved.getTargetAmount());
        } catch (DataIntegrityViolationException e) {
            log.warn("Reading goal for year {} already exists for user ID {}", currentYear, userId);
            return new ReadingGoalDTO(goal.getId(), goal.getGoalYear(), goal.getTargetAmount());
        }
    }

    @Transactional(readOnly = true)
    public ReadingStreakDTO calculateReadingStreak(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = today.with(DayOfWeek.SUNDAY);

        List<ReadingActivity> weekActivities = readingActivityRepository
                .findByUserIdAndActivityDateBetween(userId, weekStart, weekEnd);

        List<Boolean> weekActivity = new ArrayList<>(7);
        for (int i = 0; i < 7; i++) {
            weekActivity.add(false);
        }

        for (ReadingActivity activity : weekActivities) {
            DayOfWeek dayOfWeek = activity.getActivityDate().getDayOfWeek();
            int index = dayOfWeek.getValue() - 1; 
            if (index >= 0 && index < 7) {
                weekActivity.set(index, true);
            }
        }

        int currentStreak = calculateStreak(userId, today);

        long totalActiveDays = readingActivityRepository.countByUserIdAndActivityDateBetween(
                userId, today.minusYears(1), today);

        return new ReadingStreakDTO(currentStreak, weekActivity, totalActiveDays);
    }

    private int calculateStreak(Long userId, LocalDate today) {
        int streak = 0;
        LocalDate checkDate = today;

        while (true) {
            boolean hasActivity = readingActivityRepository.existsByUserIdAndActivityDate(userId, checkDate);
            if (hasActivity) {
                streak++;
                checkDate = checkDate.minusDays(1);
            } else {
                break;
            }
        }

        return streak;
    }

    @Transactional
    public void recordActivity(Long userId) {
        LocalDate today = LocalDate.now();
        if (!readingActivityRepository.existsByUserIdAndActivityDate(userId, today)) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
            ReadingActivity activity = new ReadingActivity();
            activity.setUser(user);
            activity.setActivityDate(today);
            try {
                readingActivityRepository.save(activity);
            } catch (DataIntegrityViolationException e) {
                log.warn("Activity for date {} already exists for user ID {}", today, userId);
            }
        }
    }

    @Transactional(readOnly = true)
    public AnnualGoalProgressDTO getAnnualGoalProgress(Long userId) {
        int currentYear = Year.now().getValue();

        int finishedCount = readingGoalRepository.countFinishedItemsByYear(userId, currentYear);

        int targetAmount = readingGoalRepository.findByUser_IdAndGoalYear(userId, currentYear)
                .map(ReadingGoal::getTargetAmount)
                .orElse(0);

        return new AnnualGoalProgressDTO(currentYear, targetAmount, finishedCount);
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
        
        try {
            readingGoalRepository.save(goal);
        } catch (DataIntegrityViolationException e) {
            log.warn("Reading goal for year {} already exists for user {}", dto.getGoalYear(), user.getEmail());
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

    @Transactional(readOnly = true)
    public Map<String, Object> getItemReadingStats(Long userId, Long itemId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("speedPagesPerHour", 0.0);
        stats.put("estimatedTimeRemainingSeconds", 0);

        long totalDurationSeconds = readingSessionRepository.findTotalDurationSecondsByItemId(userId, itemId)
                .orElse(0L);
        stats.put("totalDurationSeconds", totalDurationSeconds);

        return stats;
    }
}