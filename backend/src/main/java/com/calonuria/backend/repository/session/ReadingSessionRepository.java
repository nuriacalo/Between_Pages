package com.calonuria.backend.repository.session;

import com.calonuria.backend.model.session.ReadingSession;
import com.calonuria.backend.model.session.ReadingSession.ItemType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio JPA para sesiones de lectura.
 */
@Repository
public interface ReadingSessionRepository extends JpaRepository<ReadingSession, Long> {

    /**
     * Calcula velocidad promedio (pages/hour) del usuario para item específico o tipo.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId " +
           "AND ((:itemType IS NULL) OR (rs.itemType = :itemType)) " +
           "AND ((:itemId IS NULL) OR (rs.itemId = :itemId))")
    Optional<Double> findAverageSpeedPagesPerHour(@Param("userId") Long userId,
                                                  @Param("itemType") ItemType itemType,
                                                  @Param("itemId") Long itemId);
}
