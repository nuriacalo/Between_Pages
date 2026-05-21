package com.calonuria.backend.features.user.repository;

import com.calonuria.backend.features.user.model.ReadingActivity;
import com.calonuria.backend.features.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ReadingActivityRepository extends JpaRepository<ReadingActivity, Long> {
    boolean existsByUserAndActivityDate(User user, LocalDate activityDate);

    Optional<ReadingActivity> findByUserAndActivityDate(User user, LocalDate activityDate);

    boolean existsByUserIdAndActivityDate(Long userId, LocalDate activityDate);

    List<ReadingActivity> findByUserIdAndActivityDateBetween(Long userId, LocalDate start, LocalDate end);

    int countByUserIdAndActivityDateBetween(Long userId, LocalDate start, LocalDate end);

    @Query("SELECT r.activityDate FROM ReadingActivity r WHERE r.user.id = :userId ORDER BY r.activityDate DESC")
    List<LocalDate> findActivityDatesByUserId(@Param("userId") Long userId);
}