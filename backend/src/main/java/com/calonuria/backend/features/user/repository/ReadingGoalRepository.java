package com.calonuria.backend.features.user.repository;

import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

/**
 * Repositorio para la gestión de metas de lectura.
 */
@Repository
public interface ReadingGoalRepository extends JpaRepository<ReadingGoal, Long> {

    /**
     * Busca meta de lectura por usuario y año.
     * @param user usuario
     * @param goalYear año de la meta
     * @return Optional con la meta
     */
    Optional<ReadingGoal> findByUserAndGoalYear(User user, Integer goalYear);

    /**
     * Busca meta de lectura por ID de usuario y año.
     * @param userId ID del usuario
     * @param goalYear año de la meta
     * @return Optional con la meta
     */
    Optional<ReadingGoal> findByUserIdAndGoalYear(Long userId, Integer goalYear);
}
