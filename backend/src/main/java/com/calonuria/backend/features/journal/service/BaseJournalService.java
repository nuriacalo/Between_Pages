package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.journal.dto.BaseJournalRegistrationDTO;
import com.calonuria.backend.shared.exception.ResourceNotFoundException;
import com.calonuria.backend.features.journal.model.BaseJournal;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.journal.repository.BaseJournalRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public abstract class BaseJournalService<T extends BaseJournal, R, D extends BaseJournalRegistrationDTO>
        implements JournalService<D, R> {

    protected final BaseJournalRepository<T> journalRepository;
    protected final UserRepository userRepository;

    protected BaseJournalService(BaseJournalRepository<T> journalRepository, UserRepository userRepository) {
        this.journalRepository = journalRepository;
        this.userRepository = userRepository;
    }

    public abstract R saveProgress(D dto);

    protected abstract R mapToDTO(T journal);

    @Override
    @Transactional(readOnly = true)
    public List<R> getUserJournal(Long userId) {
        return journalRepository.findByUserId(userId)
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<R> getByStatus(Long userId, String status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));
        return journalRepository.findByUserAndStatus(user, status)
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<R> getRereadings(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));
        return journalRepository.findByUserAndRereadingTrue(user)
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

    @Override
    public void deleteJournal(Long journalId) {
        journalRepository.deleteById(journalId);
    }
}
