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

    @Query("SELECT EXISTS(SELECT 1 FROM ReadingActivity r WHERE r.user.id = :userId AND r.activityDate = :activityDate)")
    boolean existsByUserIdAndActivityDate(@Param("userId") Long userId, @Param("activityDate") LocalDate activityDate);

    @Query("SELECT r FROM ReadingActivity r WHERE r.user.id = :userId AND r.activityDate BETWEEN :start AND :end")
    List<ReadingActivity> findByUserIdAndActivityDateBetween(@Param("userId") Long userId, @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT COUNT(r) FROM ReadingActivity r WHERE r.user.id = :userId AND r.activityDate BETWEEN :start AND :end")
    int countByUserIdAndActivityDateBetween(@Param("userId") Long userId, @Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT r.activityDate FROM ReadingActivity r WHERE r.user.id = :userId ORDER BY r.activityDate DESC")
    List<LocalDate> findActivityDatesByUserId(@Param("userId") Long userId);
}