package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.journal.model.BookJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BookJournalRepository extends BaseJournalRepository<BookJournal> {

    Optional<BookJournal> findByUserAndBook(User user, com.calonuria.backend.features.catalog.model.Book book);

    List<BookJournal> findByUserAndRating(User user, Integer rating);

    List<BookJournal> findByUserAndRatingGreaterThanEqual(User user, Integer rating);

    @Query("SELECT COUNT(b) FROM BookJournal b WHERE b.user.id = :userId AND b.status = :status AND EXTRACT(YEAR FROM b.endDate) = :year")
    int countByUserAndStatusAndYear(@Param("userId") Long userId, @Param("status") String status, @Param("year") int year);
}