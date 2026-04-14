package com.calonuria.backend.repository.journal;

import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.model.journal.BookJournal;
import com.calonuria.backend.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de diarios de lectura de libros.
 */
@Repository
public interface BookJournalRepository extends JpaRepository<BookJournal, Long> {

    /**
     * Busca todos los diarios de un usuario.
     * @param userId ID del usuario
     * @return lista de diarios
     */
    @Query("SELECT b FROM BookJournal b WHERE b.user.id = :userId")
    List<BookJournal> findByUserId(@Param("userId") Long userId);

    /**
     * Busca una entrada específica de un usuario para un libro.
     * @param user usuario
     * @param book libro
     * @return Optional con el diario
     */
    Optional<BookJournal> findByUserAndBook(User user, Book book);

    /**
     * Busca diarios por estado.
     * @param user usuario
     * @param status estado de lectura
     * @return lista de diarios
     */
    List<BookJournal> findByUserAndStatus(User user, String status);

    /**
     * Busca diarios por valoración exacta.
     * @param user usuario
     * @param rating valoración
     * @return lista de diarios
     */
    List<BookJournal> findByUserAndRating(User user, Integer rating);

    /**
     * Busca diarios con valoración mínima.
     * @param user usuario
     * @param rating valoración mínima
     * @return lista de diarios
     */
    List<BookJournal> findByUserAndRatingGreaterThanEqual(User user, Integer rating);

    /**
     * Busca libros finalizados en un rango de fechas.
     * @param user usuario
     * @param start fecha inicial
     * @param end fecha final
     * @return lista de diarios
     */
    List<BookJournal> findByUserAndEndDateBetween(User user, LocalDate start, LocalDate end);

    /**
     * Busca libros iniciados en un rango de fechas.
     * @param user usuario
     * @param start fecha inicial
     * @param end fecha final
     * @return lista de diarios
     */
    List<BookJournal> findByUserAndStartDateBetween(User user, LocalDate start, LocalDate end);

    /**
     * Busca solo relecturas.
     * @param user usuario
     * @return lista de diarios
     */
    List<BookJournal> findByUserAndRereadingTrue(User user);
}