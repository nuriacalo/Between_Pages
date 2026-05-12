package com.calonuria.backend.features.journal.service;

import java.util.List;

public interface JournalService<D, R> {

    R saveProgress(D dto);

    List<R> getUserJournal(Long userId);

    List<R> getByStatus(Long userId, String status);

    List<R> getRereadings(Long userId);

    void deleteJournal(Long journalId);
}
