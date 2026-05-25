package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.journal.dto.BaseJournalRegistrationDTO;
import com.calonuria.backend.features.journal.model.BaseJournal;
import com.calonuria.backend.features.journal.repository.BaseJournalRepository;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BaseJournalServiceTest {

    @Mock
    private BaseJournalRepository<BaseJournal> journalRepository;

    @Mock
    private UserRepository userRepository;

    private BaseJournalService<BaseJournal, Object, BaseJournalRegistrationDTO> baseJournalService;

    @BeforeEach
    void setUp() {
        baseJournalService = new BaseJournalService<BaseJournal, Object, BaseJournalRegistrationDTO>(journalRepository, userRepository) {
            @Override
            public Object saveProgress(BaseJournalRegistrationDTO dto) {
                return null;
            }

            @Override
            protected Object mapToDTO(BaseJournal journal) {
                return new Object();
            }
        };
    }

    @Test
    void getUserJournal() {
        when(journalRepository.findByUserId(1L)).thenReturn(Collections.emptyList());
        assertNotNull(baseJournalService.getUserJournal(1L));
    }

    @Test
    void getByStatus() {
        User user = new User();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(journalRepository.findByUserAndStatus(user, "READING")).thenReturn(Collections.emptyList());
        assertNotNull(baseJournalService.getByStatus(1L, "READING"));
    }

    @Test
    void getRereadings() {
        User user = new User();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(journalRepository.findByUserAndRereadingTrue(user)).thenReturn(Collections.emptyList());
        assertNotNull(baseJournalService.getRereadings(1L));
    }
}