package com.calonuria.backend.features.user.repository;

import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ReadingGoalRepository extends JpaRepository<ReadingGoal, Long> {
    Optional<ReadingGoal> findByUser_IdAndGoalYear(Long userId, int goalYear);

    Optional<ReadingGoal> findByUserAndGoalYear(User user, Integer goalYear);

    @Query(value = """
        SELECT COUNT(*)
        FROM (
            SELECT user_id, end_date FROM book_journal WHERE status = 'FINISHED'
            UNION ALL
            SELECT user_id, end_date FROM manga_journal WHERE status = 'FINISHED'
            UNION ALL
            SELECT user_id, end_date FROM fanfic_journal WHERE status = 'FINISHED'
        ) AS all_finished_items
        WHERE user_id = :userId
          AND EXTRACT(YEAR FROM COALESCE(end_date, CURRENT_DATE)) = :year
    """, nativeQuery = true)
    int countFinishedItemsByYear(@Param("userId") Long userId, @Param("year") int year);
}