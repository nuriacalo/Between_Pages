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
import java.time.temporal.ChronoUnit; // Import added
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
    public ReadingStreakDTO calculateReadingStreak(Long userId, LocalDate today) {
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = today.with(DayOfWeek.SUNDAY);

        List<ReadingActivity> weekActivities = readingActivityRepository
                .findByUserIdAndActivityDateBetween(userId, weekStart, weekEnd);

        // The streak should now be directly from the User entity
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
        int currentStreak = user.getCurrentStreak(); // Get streak from User entity
        LocalDate lastReadingDate = user.getLastReadingDate();

        // Si ha pasado más de 1 día desde la última lectura, la racha se ha roto
        if (lastReadingDate != null) {
            long daysSinceLastRead = ChronoUnit.DAYS.between(lastReadingDate, today);
            if (daysSinceLastRead > 1) {
                currentStreak = 0;
            }
        }

        // Determinar el inicio de la racha actual para colorear solo esos días
        LocalDate currentStreakStart = null;
        if (lastReadingDate != null && currentStreak > 0) {
            currentStreakStart = lastReadingDate.minusDays(currentStreak - 1);
        }

        List<Boolean> weekActivity = new ArrayList<>(7);
        for (int i = 0; i < 7; i++) {
            weekActivity.add(false);
        }

        for (ReadingActivity activity : weekActivities) {
            LocalDate activityDate = activity.getActivityDate();
            boolean isPartOfCurrentStreak = currentStreakStart != null && 
                                            !activityDate.isBefore(currentStreakStart) && 
                                            !activityDate.isAfter(lastReadingDate);

            if (isPartOfCurrentStreak) {
                DayOfWeek dayOfWeek = activityDate.getDayOfWeek();
                int index = dayOfWeek.getValue() - 1; 
                if (index >= 0 && index < 7) {
                    weekActivity.set(index, true);
                }
            }
        }

        long totalActiveDays = readingActivityRepository.countByUserIdAndActivityDateBetween(
                userId, today.minusYears(1), today);

        return new ReadingStreakDTO(currentStreak, weekActivity, totalActiveDays);
    }

    // This method is no longer needed for calculating the main streak, as it's stored in User
    // private int calculateStreak(Long userId, LocalDate today) {
    //     int streak = 0;
    //     LocalDate checkDate = today;

    //     while (true) {
    //         boolean hasActivity = readingActivityRepository.existsByUserIdAndActivityDate(userId, checkDate);
    //         if (hasActivity) {
    //             streak++;
    //             checkDate = checkDate.minusDays(1);
    //         } else {
    //             break;
    //         }
    //     }
    //     return streak;
    // }

    @Transactional
    public void recordActivity(Long userId, String localDateString) { // Modified to accept localDateString
        LocalDate today = LocalDate.parse(localDateString); // Parse the localDateString

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        // Check if an activity for today already exists to avoid duplicate entries
        if (!readingActivityRepository.existsByUserIdAndActivityDate(userId, today)) {
            ReadingActivity activity = new ReadingActivity();
            activity.setUser(user);
            activity.setActivityDate(today);
            try {
                readingActivityRepository.save(activity);
            } catch (DataIntegrityViolationException e) {
                log.warn("Activity for date {} already exists for user ID {}", today, userId);
            }
        }

        // Streak calculation logic
        LocalDate lastActivityDate = user.getLastReadingDate();

        if (lastActivityDate == null) {
            // First activity for the user
            user.setCurrentStreak(1);
        } else {
            long daysBetween = ChronoUnit.DAYS.between(lastActivityDate, today);

            if (daysBetween == 1) {
                // Read yesterday, streak continues
                user.setCurrentStreak(user.getCurrentStreak() + 1);
            } else if (daysBetween > 1) {
                // Did not read yesterday, streak resets
                user.setCurrentStreak(1);
            }
            // If daysBetween == 0, read today, streak remains unchanged.
            // This is important to prevent incrementing the streak if reading multiple times on the same day.
        }

        user.setLastReadingDate(today); // Update the last reading date
        userRepository.save(user); // Save the changes to the user
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

        // The streak should now be directly from the User entity
        int currentStreak = user.getCurrentStreak(); // Get streak from User entity
        LocalDate lastReadingDate = user.getLastReadingDate();
        LocalDate today = LocalDate.now();

        // Validar rotura de racha caducada
        if (lastReadingDate != null) {
            long daysSinceLastRead = ChronoUnit.DAYS.between(lastReadingDate, today);
            if (daysSinceLastRead > 1) {
                currentStreak = 0;
            }
        }

        LocalDate currentStreakStart = null;
        if (lastReadingDate != null && currentStreak > 0) {
            currentStreakStart = lastReadingDate.minusDays(currentStreak - 1);
        }

        List<Boolean> weekActivity = new ArrayList<>();
        
        // This part still relies on ReadingActivity, which is fine for weekly activity visualization
        for (int i = 6; i >= 0; i--) {
            LocalDate targetDate = today.minusDays(i);
            boolean hasActivity = readingActivityRepository.existsByUserIdAndActivityDate(user.getId(), targetDate);
            boolean isPartOfCurrentStreak = currentStreakStart != null && 
                                            !targetDate.isBefore(currentStreakStart) && 
                                            !targetDate.isAfter(lastReadingDate);
            weekActivity.add(hasActivity && isPartOfCurrentStreak);
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

    // This calculateStreak method is no longer directly used for the main streak value,
    // as it's now managed in the User entity. It might be useful for historical calculations
    // or specific reports, but for the current streak, we rely on the User entity.
    private int calculateStreak(List<LocalDate> sortedDates) {
        if (sortedDates == null || sortedDates.isEmpty()) {
            return 0;
        }

        LocalDate currentDate = LocalDate.now();
        int streak = 0;
        LocalDate expectedDate;

        if (sortedDates.contains(currentDate)) { // Check if today's activity is present
            streak = 1;
            expectedDate = currentDate.minusDays(1);
        } else if (sortedDates.contains(currentDate.minusDays(1))) { // Check if yesterday's activity is present
            streak = 1;
            expectedDate = currentDate.minusDays(2);
        } else {
            return 0;
        }

        // Sort dates in descending order to easily check consecutive days backwards
        sortedDates.sort((d1, d2) -> d2.compareTo(d1));

        for (LocalDate date : sortedDates) {
            if (date.equals(currentDate)) continue; // Skip today if already handled

            if (date.equals(expectedDate)) {
                streak++;
                expectedDate = expectedDate.minusDays(1);
            } else if (date.isBefore(expectedDate)) {
                // If a date is before the expected date, the streak is broken
                break;
            }
            // If date is after expectedDate (meaning it's a future date or a duplicate of today), ignore
        }

        return streak;
    }


    @Transactional(readOnly = true)
    public Map<String, Object> getItemReadingStats(Long userId, Long itemId, String itemType) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("estimatedTimeRemainingSeconds", 0);

        long totalDurationSeconds = readingSessionRepository.findTotalDurationSecondsByItemId(userId, itemId, itemType)
                .orElse(0L);

        Long bookId = "BOOK".equals(itemType) ? itemId : null;
        Long mangaId = "MANGA".equals(itemType) ? itemId : null;
        Long fanficId = "FANFIC".equals(itemType) ? itemId : null;

        Double averageSpeed = readingSessionRepository.findAverageSpeedForItem(userId, bookId, mangaId, fanficId)
                .orElse(0.0);

        stats.put("totalDurationSeconds", totalDurationSeconds);
        stats.put("speedPagesPerHour", averageSpeed);

        return stats;
    }
}