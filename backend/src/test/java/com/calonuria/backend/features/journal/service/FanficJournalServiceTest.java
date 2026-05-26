package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.search.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.service.FanfictionService;
import com.calonuria.backend.features.journal.dto.FanficJournalRegistrationDTO;
import com.calonuria.backend.features.journal.model.FanficJournal;
import com.calonuria.backend.features.journal.repository.FanficJournalRepository;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class FanficJournalServiceTest {

    @Mock
    private FanficJournalRepository fanficJournalRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private FanfictionService fanfictionService;

    @InjectMocks
    private FanficJournalService fanficJournalService;

    @Test
    void saveProgress_newJournal() {
        FanficJournalRegistrationDTO dto = new FanficJournalRegistrationDTO();
        dto.setUserId(1L);
        dto.setAo3Id("testId");

        User user = new User();
        user.setId(1L);
        Fanfiction fanfic = new Fanfiction();
        FanficJournal savedJournal = new FanficJournal();
        savedJournal.setUser(user);
        savedJournal.setFanfic(fanfic);


        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(fanfictionService.findOrCreate(null, "testId")).thenReturn(fanfic);
        when(fanficJournalRepository.findByUserAndFanfic(user, fanfic)).thenReturn(Optional.empty());
        when(fanficJournalRepository.save(any(FanficJournal.class))).thenReturn(savedJournal);
        when(fanfictionService.mapToDTO(any(Fanfiction.class))).thenReturn(new FanfictionResponseDTO());


        assertNotNull(fanficJournalService.saveProgress(dto));
    }

    @Test
    void saveProgress_existingJournal() {
        FanficJournalRegistrationDTO dto = new FanficJournalRegistrationDTO();
        dto.setUserId(1L);
        dto.setAo3Id("testId");

        User user = new User();
        user.setId(1L);
        Fanfiction fanfic = new Fanfiction();
        FanficJournal journal = new FanficJournal();
        journal.setUser(user);
        journal.setFanfic(fanfic);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(fanfictionService.findOrCreate(null, "testId")).thenReturn(fanfic);
        when(fanficJournalRepository.findByUserAndFanfic(user, fanfic)).thenReturn(Optional.of(journal));
        when(fanficJournalRepository.save(any(FanficJournal.class))).thenReturn(journal);
        when(fanfictionService.mapToDTO(any(Fanfiction.class))).thenReturn(new FanfictionResponseDTO());

        assertNotNull(fanficJournalService.saveProgress(dto));
    }
}