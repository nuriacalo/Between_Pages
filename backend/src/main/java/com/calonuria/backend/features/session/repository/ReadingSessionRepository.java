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
           "AND (:bookId IS NULL OR rs.book.id = :bookId) " +
           "AND (:mangaId IS NULL OR rs.manga.id = :mangaId) " +
           "AND (:fanficId IS NULL OR rs.fanfic.id = :fanficId)")
    Optional<Double> findAverageSpeedForItem(@Param("userId") Long userId,
                                             @Param("bookId") Long bookId,
                                             @Param("mangaId") Long mangaId,
                                             @Param("fanficId") Long fanficId);

    /**
     * Calcula la velocidad promedio para todos los libros de un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId AND rs.book IS NOT NULL")
    Optional<Double> findAverageSpeedForBookType(@Param("userId") Long userId);

    /**
     * Calcula la velocidad promedio para todos los mangas de un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId AND rs.manga IS NOT NULL")
    Optional<Double> findAverageSpeedForMangaType(@Param("userId") Long userId);

    /**
     * Calcula la velocidad promedio para todos los fanfics de un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId AND rs.fanfic IS NOT NULL")
    Optional<Double> findAverageSpeedForFanficType(@Param("userId") Long userId);
    
    /**
     * Calcula la velocidad promedio global para un usuario.
     */
    @Query("SELECT AVG(CAST(rs.pagesRead AS double) / (CAST(rs.durationSeconds AS double) / 3600)) " +
           "FROM ReadingSession rs WHERE rs.user.id = :userId")
    Optional<Double> findAverageSpeedGlobal(@Param("userId") Long userId);

    /**
     * Calcula la duración total de lectura en segundos para un item específico.
     */
    @Query("SELECT SUM(rs.durationSeconds) FROM ReadingSession rs WHERE rs.user.id = :userId " +
           "AND (:bookId IS NULL OR rs.book.id = :bookId) " +
           "AND (:mangaId IS NULL OR rs.manga.id = :mangaId) " +
           "AND (:fanficId IS NULL OR rs.fanfic.id = :fanficId)")
    Optional<Long> findTotalDurationSeconds(@Param("userId") Long userId,
                                            @Param("bookId") Long bookId,
                                            @Param("mangaId") Long mangaId,
                                            @Param("fanficId") Long fanficId);

    @Query("SELECT SUM(rs.durationSeconds) FROM ReadingSession rs WHERE rs.user.id = :userId AND " +
           "((:itemType = 'BOOK' AND rs.book.id = :itemId) OR " +
           "(:itemType = 'MANGA' AND rs.manga.id = :itemId) OR " +
           "(:itemType = 'FANFIC' AND rs.fanfic.id = :itemId))")
    Optional<Long> findTotalDurationSecondsByItemId(@Param("userId") Long userId, @Param("itemId") Long itemId, @Param("itemType") String itemType);
}