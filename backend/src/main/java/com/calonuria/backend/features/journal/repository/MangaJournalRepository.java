package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.journal.model.MangaJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MangaJournalRepository extends BaseJournalRepository<MangaJournal> {

    Optional<MangaJournal> findByUserAndManga(User user, com.calonuria.backend.features.catalog.model.Manga manga);

    List<MangaJournal> findByUserAndRating(User user, Integer rating);

    List<MangaJournal> findByUserAndRatingGreaterThanEqual(User user, Integer rating);

    @Query("SELECT COUNT(m) FROM MangaJournal m WHERE m.user.id = :userId AND m.status = :status AND EXTRACT(YEAR FROM m.endDate) = :year")
    int countByUserAndStatusAndYear(@Param("userId") Long userId, @Param("status") String status, @Param("year") int year);
}