package com.calonuria.backend.service.journal;

import com.calonuria.backend.dto.journal.BaseJournalRegistrationDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.journal.BaseJournal;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.journal.BaseJournalRepository;
import com.calonuria.backend.repository.user.UserRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

public abstract class BaseJournalService<T extends BaseJournal, D, R extends BaseJournalRegistrationDTO> {

    protected final BaseJournalRepository<T> journalRepository;
    protected final UserRepository userRepository;

    protected BaseJournalService(BaseJournalRepository<T> journalRepository, UserRepository userRepository) {
        this.journalRepository = journalRepository;
        this.userRepository = userRepository;
    }

    public abstract D saveProgress(R dto);

    protected abstract D mapToDTO(T journal);

    @Transactional(readOnly = true)
    public List<D> getUserJournal(Long userId) {
        return journalRepository.findByUserId(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<D> getByStatus(Long userId, String status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));
        return journalRepository.findByUserAndStatus(user, status)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<D> getRereadings(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado con id: " + userId));
        return journalRepository.findByUserAndRereadingTrue(user)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public void deleteJournal(Long journalId) {
        journalRepository.deleteById(journalId);
    }
}
