package com.calonuria.backend.repository.journal;

import com.calonuria.backend.model.catalog.Fanfiction;
import com.calonuria.backend.model.journal.FanficJournal;
import com.calonuria.backend.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de diarios de lectura de fanfiction.
 */
@Repository
public interface FanficJournalRepository extends JpaRepository<FanficJournal, Long> {

    /**
     * Busca todos los diarios de un usuario.
     * @param userId ID del usuario
     * @return lista de diarios
     */
    @Query("SELECT f FROM FanficJournal f WHERE f.user.id = :userId")
    List<FanficJournal> findByUserId(@Param("userId") Long userId);

    /**
     * Busca una entrada específica de un usuario para un fanfiction.
     * @param user usuario
     * @param fanfic fanfiction
     * @return Optional con el diario
     */
    Optional<FanficJournal> findByUserAndFanfic(User user, Fanfiction fanfic);

    /**
     * Busca diarios por estado.
     * @param user usuario
     * @param status estado de lectura
     * @return lista de diarios
     */
    List<FanficJournal> findByUserAndStatus(User user, String status);

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
     * Busca solo relecturas.
     * @param user usuario
     * @return lista de diarios
     */
    List<FanficJournal> findByUserAndRereadingTrue(User user);

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