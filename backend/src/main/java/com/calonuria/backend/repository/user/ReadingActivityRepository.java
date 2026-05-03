package com.calonuria.backend.repository.user;

import com.calonuria.backend.model.user.ReadingActivity;
import com.calonuria.backend.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReadingActivityRepository extends JpaRepository<ReadingActivity, Long> {

    /**
     * Obtiene todas las fechas únicas en las que un usuario ha leído, ordenadas de la más reciente a la más antigua.
     * @param userId ID del usuario
     * @return Lista de fechas de actividad
     */
    @Query("SELECT r.activityDate FROM ReadingActivity r WHERE r.user.id = :userId ORDER BY r.activityDate DESC")
    List<LocalDate> findActivityDatesByUserId(Long userId);

    Optional<ReadingActivity> findByUserAndActivityDate(User user, LocalDate activityDate);
}