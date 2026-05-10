package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.user.dto.ReadingGoalDTO;
import com.calonuria.backend.features.user.dto.ReadingStreakDTO;
import com.calonuria.backend.features.user.model.ReadingActivity;
import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.ReadingActivityRepository;
import com.calonuria.backend.features.user.repository.ReadingGoalRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio para gestionar estadísticas de lectura del usuario:
 * - Meta anual de lectura
 * - Racha de lectura
 * - Actividad semanal
 */
@Service
@RequiredArgsConstructor
public class ReadingStatsService {

    private final ReadingGoalRepository readingGoalRepository;
    private final ReadingActivityRepository readingActivityRepository;
    private final UserRepository userRepository;

    /**
     * Obtiene la meta de lectura del usuario para el año actual.
     * Si no existe, crea una meta por defecto de 12 libros.
     *
     * @param userId ID del usuario
     * @return DTO con la meta de lectura
     */
    @Transactional(readOnly = true)
    public ReadingGoalDTO getOrCreateReadingGoal(Long userId) {
        int currentYear = LocalDate.now().getYear();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Optional<ReadingGoal> existingGoal = readingGoalRepository.findByUserAndGoalYear(user, currentYear);

        if (existingGoal.isPresent()) {
            ReadingGoal goal = existingGoal.get();
            return new ReadingGoalDTO(goal.getId(), goal.getGoalYear(), goal.getTargetAmount());
        }

        // Crear meta por defecto de 12 libros para usuarios nuevos
        ReadingGoal newGoal = new ReadingGoal();
        newGoal.setUser(user);
        newGoal.setGoalYear(currentYear);
        newGoal.setTargetAmount(12);
        ReadingGoal saved = readingGoalRepository.save(newGoal);

        return new ReadingGoalDTO(saved.getId(), saved.getGoalYear(), saved.getTargetAmount());
    }

    /**
     * Actualiza la meta de lectura del usuario.
     *
     * @param userId ID del usuario
     * @param targetAmount nueva cantidad objetivo
     * @return DTO con la meta actualizada
     */
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
        ReadingGoal saved = readingGoalRepository.save(goal);

        return new ReadingGoalDTO(saved.getId(), saved.getGoalYear(), saved.getTargetAmount());
    }

    /**
     * Calcula la racha de lectura actual y la actividad de la última semana.
     *
     * @param userId ID del usuario
     * @return DTO con racha y actividad semanal
     */
    @Transactional(readOnly = true)
    public ReadingStreakDTO calculateReadingStreak(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = today.with(DayOfWeek.SUNDAY);

        // Obtener actividad de la última semana
        List<ReadingActivity> weekActivities = readingActivityRepository
                .findByUserIdAndActivityDateBetween(userId, weekStart, weekEnd);

        // Construir array de actividad diaria (lunes = índice 0)
        List<Boolean> weekActivity = new ArrayList<>(7);
        for (int i = 0; i < 7; i++) {
            weekActivity.add(false);
        }

        for (ReadingActivity activity : weekActivities) {
            DayOfWeek dayOfWeek = activity.getActivityDate().getDayOfWeek();
            int index = dayOfWeek.getValue() - 1; // Monday=1 -> index=0
            if (index >= 0 && index < 7) {
                weekActivity.set(index, true);
            }
        }

        // Calcular racha actual
        int currentStreak = calculateStreak(userId, today);

        // Contar días activos totales
        long totalActiveDays = readingActivityRepository.countByUserIdAndActivityDateBetween(
                userId, today.minusYears(1), today);

        return new ReadingStreakDTO(currentStreak, weekActivity, totalActiveDays);
    }

    /**
     * Calcula la racha actual de días consecutivos con actividad de lectura.
     *
     * @param userId ID del usuario
     * @param today fecha actual
     * @return número de días consecutivos
     */
    private int calculateStreak(Long userId, LocalDate today) {
        int streak = 0;
        LocalDate checkDate = today;

        // Retroceder día por día mientras haya actividad
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

    /**
     * Registra actividad de lectura para el usuario en la fecha actual.
     * Se llama automáticamente cuando el usuario actualiza progreso o marca como leído.
     *
     * @param userId ID del usuario
     */
    @Transactional
    public void recordActivity(Long userId) {
        LocalDate today = LocalDate.now();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Verificar si ya existe actividad hoy
        Optional<ReadingActivity> existingActivity = readingActivityRepository
                .findByUserAndActivityDate(user, today);

        if (existingActivity.isEmpty()) {
            ReadingActivity activity = new ReadingActivity();
            activity.setUser(user);
            activity.setActivityDate(today);
            readingActivityRepository.save(activity);
        }
    }
}
