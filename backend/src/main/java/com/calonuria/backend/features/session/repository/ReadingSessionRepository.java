package com.calonuria.backend.features.session.repository;

import com.calonuria.backend.features.session.model.ReadingSession;
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
     * Calcula la velocidad promedio (páginas/hora) para un item específico.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId " +
           "AND (:bookId IS NULL OR (rs.itemType = 'BOOK' AND rs.itemId = :bookId)) " +
           "AND (:mangaId IS NULL OR (rs.itemType = 'MANGA' AND rs.itemId = :mangaId)) " +
           "AND (:fanficId IS NULL OR (rs.itemType = 'FANFIC' AND rs.itemId = :fanficId))")
    Optional<Double> findAverageSpeedForItem(@Param("userId") Long userId,
                                             @Param("bookId") Long bookId,
                                             @Param("mangaId") Long mangaId,
                                             @Param("fanficId") Long fanficId);

    /**
     * Calcula la velocidad promedio para todos los libros de un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId AND rs.itemType = 'BOOK'")
    Optional<Double> findAverageSpeedForBookType(@Param("userId") Long userId);

    /**
     * Calcula la velocidad promedio para todos los mangas de un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId AND rs.itemType = 'MANGA'")
    Optional<Double> findAverageSpeedForMangaType(@Param("userId") Long userId);

    /**
     * Calcula la velocidad promedio para todos los fanfics de un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId AND rs.itemType = 'FANFIC'")
    Optional<Double> findAverageSpeedForFanficType(@Param("userId") Long userId);
    
    /**
     * Calcula la velocidad promedio global para un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId")
    Optional<Double> findAverageSpeedGlobal(@Param("userId") Long userId);
}
