package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.journal.repository.BookJournalRepository;
import com.calonuria.backend.features.journal.repository.FanficJournalRepository;
import com.calonuria.backend.features.journal.repository.MangaJournalRepository;
import com.calonuria.backend.features.user.model.ReadingGoal;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.ReadingGoalRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;

import java.time.Year;
import java.util.Map;

@Service
public class ProfileService {

    private final ReadingGoalRepository readingGoalRepository;
    private final BookJournalRepository bookJournalRepository;
    private final MangaJournalRepository mangaJournalRepository;
    private final FanficJournalRepository fanficJournalRepository;
    private final UserRepository userRepository;

    public ProfileService(ReadingGoalRepository readingGoalRepository,
                          BookJournalRepository bookJournalRepository,
                          MangaJournalRepository mangaJournalRepository,
                          FanficJournalRepository fanficJournalRepository,
                          UserRepository userRepository) {
        this.readingGoalRepository = readingGoalRepository;
        this.bookJournalRepository = bookJournalRepository;
        this.mangaJournalRepository = mangaJournalRepository;
        this.fanficJournalRepository = fanficJournalRepository;
        this.userRepository = userRepository;
    }

    public Map<String, Integer> getAnnualGoal(Long userId) {
        int year = Year.now().getValue();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        ReadingGoal goal = readingGoalRepository.findByUserAndGoalYear(user, year)
                .orElse(new ReadingGoal(null, user, year, 0));
        
        int completedBooks = bookJournalRepository.countByUserAndStatusAndYear(userId, "FINISHED", year);
        int completedManga = mangaJournalRepository.countByUserAndStatusAndYear(userId, "FINISHED", year);
        int completedFanfics = fanficJournalRepository.countByUserAndStatusAndYear(userId, "FINISHED", year);

        int completed = completedBooks + completedManga + completedFanfics;

        return Map.of("target", goal.getTargetAmount(), "completed", completed);
    }

    public void setAnnualGoal(Long userId, int target) {
        int year = Year.now().getValue();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        ReadingGoal goal = readingGoalRepository.findByUserAndGoalYear(user, year)
                .orElse(new ReadingGoal(null, user, year, 0));
        goal.setTargetAmount(target);
        readingGoalRepository.save(goal);
    }
}