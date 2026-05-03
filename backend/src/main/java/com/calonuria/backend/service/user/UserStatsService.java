package com.calonuria.backend.service.user;

import com.calonuria.backend.dto.user.StreakResponseDTO;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DEPRECATED: Use ReadingStatsService instead.
 * Este servicio ha sido consolidado en ReadingStatsService para evitar duplicación.
 * Esta clase se mantiene solo para compatibilidad histórica.
 */
@Deprecated
@Service
@RequiredArgsConstructor
public class UserStatsService {

    private final UserRepository userRepository;
    private final ReadingActivityRepository readingActivityRepository;

    /**
     * DEPRECATED: Use ReadingStatsService.calculateReadingStreak() instead.
     * Calcula la racha actual de lectura y la actividad de la semana en curso.
     * 
     * @param email Correo electrónico del usuario
     * @return Objeto DTO con los días de racha y el estado semanal
     * @deprecated Migrado a ReadingStatsService.calculateReadingStreak()
     */
    @Deprecated
    @Transactional(readOnly = true)
    public StreakResponseDTO getUserStreak(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con email: " + email));

        List<LocalDate> activityDates = readingActivityRepository.findActivityDatesByUserId(user.getId());
        
        StreakResponseDTO dto = new StreakResponseDTO();
        
        // 1. Calcular la racha actual (Current Streak)
        int currentStreak = 0;
        LocalDate today = LocalDate.now();
        LocalDate dateToCheck = today;

        // Si no ha leído hoy, verificamos si leyó ayer. Si tampoco leyó ayer, la racha se ha perdido (es 0).
        if (!activityDates.contains(today) && activityDates.contains(today.minusDays(1))) {
            dateToCheck = today.minusDays(1);
        }

        // Contamos hacia atrás mientras existan días consecutivos en el registro
        while (activityDates.contains(dateToCheck)) {
            currentStreak++;
            dateToCheck = dateToCheck.minusDays(1);
        }
        dto.setCurrentStreak(currentStreak);

        // 2. Calcular la actividad de la semana actual (Lunes a Domingo)
        LocalDate startOfWeek = today.with(DayOfWeek.MONDAY);
        List<Boolean> weeklyActivity = new ArrayList<>();
        
        for (int i = 0; i < 7; i++) {
            LocalDate dayInWeek = startOfWeek.plusDays(i);
            weeklyActivity.add(activityDates.contains(dayInWeek));
        }
        
        dto.setWeeklyActivity(weeklyActivity);
        return dto;
    }
}