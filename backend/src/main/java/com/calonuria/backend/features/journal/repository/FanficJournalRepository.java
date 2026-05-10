package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.journal.model.FanficJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de diarios de lectura de fanfiction.
 */
@Repository
public interface FanficJournalRepository extends BaseJournalRepository<FanficJournal> {

    /**
     * Busca una entrada específica de un usuario para un fanfiction.
     * @param user usuario
     * @param fanfic fanfiction
     * @return Optional con el diario
     */
    Optional<FanficJournal> findByUserAndFanfic(User user, Fanfiction fanfic);

    /**
     * Busca diarios por valoración exacta.
     * @param user usuario
     * @param rating valoración
     * @return lista de diarios
     */
    List<FanficJournal> findByUserAndRating(User user, Integer rating);

    /**
     * Busca diarios con valoración mínima.
     * @param user usuario
     * @param rating valoración mínima
     * @return lista de diarios
     */
    List<FanficJournal> findByUserAndRatingGreaterThanEqual(User user, Integer rating);

    /**
     * Busca diarios por nivel de angst.
     * @param user usuario
     * @param angstLevel nivel de angst
     * @return lista de diarios
     */
    List<FanficJournal> findByUserAndAngstLevel(User user, String angstLevel);

    /**
     * Busca fanfictions finalizados en un rango de fechas.
     * @param user usuario
     * @param start fecha inicial
     * @param end fecha final
     * @return lista de diarios
     */
    List<FanficJournal> findByUserAndEndDateBetween(User user, LocalDate start, LocalDate end);
}