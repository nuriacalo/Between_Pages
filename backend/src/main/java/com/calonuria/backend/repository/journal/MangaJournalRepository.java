package com.calonuria.backend.repository.journal;

import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.model.journal.MangaJournal;
import com.calonuria.backend.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de diarios de lectura de manga.
 */
@Repository
public interface MangaJournalRepository extends JpaRepository<MangaJournal, Long> {

    /**
     * Busca todos los diarios de un usuario.
     * @param userId ID del usuario
     * @return lista de diarios
     */
    @Query("SELECT m FROM MangaJournal m WHERE m.user.id = :userId")
    List<MangaJournal> findByUserId(@Param("userId") Long userId);

    /**
     * Busca una entrada específica de un usuario para un manga.
     * @param user usuario
     * @param manga manga
     * @return Optional con el diario
     */
    Optional<MangaJournal> findByUserAndManga(User user, Manga manga);

    /**
     * Busca diarios por estado.
     * @param user usuario
     * @param status estado de lectura
     * @return lista de diarios
     */
    List<MangaJournal> findByUserAndStatus(User user, String status);

    /**
     * Busca diarios por valoración exacta.
     * @param user usuario
     * @param rating valoración
     * @return lista de diarios
     */
    List<MangaJournal> findByUserAndRating(User user, Integer rating);

    /**
     * Busca diarios con valoración mínima.
     * @param user usuario
     * @param rating valoración mínima
     * @return lista de diarios
     */
    List<MangaJournal> findByUserAndRatingGreaterThanEqual(User user, Integer rating);

    /**
     * Busca mangas finalizados en un rango de fechas.
     * @param user usuario
     * @param start fecha inicial
     * @param end fecha final
     * @return lista de diarios
     */
    List<MangaJournal> findByUserAndEndDateBetween(User user, LocalDate start, LocalDate end);

    /**
     * Busca solo relecturas.
     * @param user usuario
     * @return lista de diarios
     */
    List<MangaJournal> findByUserAndRereadingTrue(User user);
}