package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.journal.model.MangaJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de diarios de lectura de manga.
 */
@Repository
public interface MangaJournalRepository extends BaseJournalRepository<MangaJournal> {

    /**
     * Busca una entrada específica de un usuario para un manga.
     * @param user usuario
     * @param manga manga
     * @return Optional con el diario
     */
    Optional<MangaJournal> findByUserAndManga(User user, Manga manga);

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
}