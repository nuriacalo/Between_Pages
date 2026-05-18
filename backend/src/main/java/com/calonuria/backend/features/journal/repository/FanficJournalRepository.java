package com.calonuria.backend.features.journal.repository;

import com.calonuria.backend.features.journal.model.FanficJournal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FanficJournalRepository extends BaseJournalRepository<FanficJournal> {

    Optional<FanficJournal> findByUserAndFanfic(User user, com.calonuria.backend.features.catalog.model.Fanfiction fanfic);

    List<FanficJournal> findByUserAndRating(User user, Integer rating);

    List<FanficJournal> findByUserAndRatingGreaterThanEqual(User user, Integer rating);

    @Query("SELECT COUNT(f) FROM FanficJournal f WHERE f.user.id = :userId AND f.status = :status AND EXTRACT(YEAR FROM f.endDate) = :year")
    int countByUserAndStatusAndYear(@Param("userId") Long userId, @Param("status") String status, @Param("year") int year);
}