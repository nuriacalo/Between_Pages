package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.journal.model.BookJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de diarios de lectura de libros.
 */
@Repository
public interface BookJournalRepository extends BaseJournalRepository<BookJournal> {

    /**
     * Busca una entrada específica de un usuario para un libro.
     * @param user usuario
     * @param book libro
     * @return Optional con el diario
     */
    Optional<BookJournal> findByUserAndBook(User user, Book book);

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
}