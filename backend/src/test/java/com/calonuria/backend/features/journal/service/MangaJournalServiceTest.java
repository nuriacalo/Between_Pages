package com.calonuria.backend.features.journal.service;

import com.calonuria.backend.features.catalog.dto.MangaResponseDTO;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.service.MangaService;
import com.calonuria.backend.features.journal.dto.MangaJournalRegistrationDTO;
import com.calonuria.backend.features.journal.model.MangaJournal;
import com.calonuria.backend.features.journal.repository.MangaJournalRepository;
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
class MangaJournalServiceTest {

    @Mock
    private MangaJournalRepository mangaJournalRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private MangaService mangaService;

    @InjectMocks
    private MangaJournalService mangaJournalService;

    @Test
    void saveProgress_newJournal() {
        MangaJournalRegistrationDTO dto = new MangaJournalRegistrationDTO();
        dto.setUserId(1L);
        dto.setMalId(1);

        User user = new User();
        user.setId(1L);
        Manga manga = new Manga();
        MangaJournal savedJournal = new MangaJournal();
        savedJournal.setUser(user);
        savedJournal.setManga(manga);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(mangaService.findOrCreate(null, 1)).thenReturn(manga);
        when(mangaJournalRepository.findByUserAndManga(user, manga)).thenReturn(Optional.empty());
        when(mangaJournalRepository.save(any(MangaJournal.class))).thenReturn(savedJournal);
        when(mangaService.mapToDTO(any(Manga.class))).thenReturn(new MangaResponseDTO());

        assertNotNull(mangaJournalService.saveProgress(dto));
    }

    @Test
    void saveProgress_existingJournal() {
        MangaJournalRegistrationDTO dto = new MangaJournalRegistrationDTO();
        dto.setUserId(1L);
        dto.setMalId(1);

        User user = new User();
        user.setId(1L);
        Manga manga = new Manga();
        MangaJournal journal = new MangaJournal();
        journal.setUser(user);
        journal.setManga(manga);

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(mangaService.findOrCreate(null, 1)).thenReturn(manga);
        when(mangaJournalRepository.findByUserAndManga(user, manga)).thenReturn(Optional.of(journal));
        when(mangaJournalRepository.save(any(MangaJournal.class))).thenReturn(journal);
        when(mangaService.mapToDTO(any(Manga.class))).thenReturn(new MangaResponseDTO());

        assertNotNull(mangaJournalService.saveProgress(dto));
    }
}