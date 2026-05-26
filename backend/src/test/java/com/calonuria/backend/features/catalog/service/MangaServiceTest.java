package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.repository.MangaRepository;
import com.calonuria.backend.features.search.dto.MangaResponseDTO;
import com.calonuria.backend.features.search.service.JikanService;
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
class MangaServiceTest {

    @Mock
    private MangaRepository mangaRepository;

    @Mock
    private JikanService jikanService;

    @InjectMocks
    private MangaService mangaService;

    @Test
    void findOrCreate_withMangaId() {
        Manga manga = new Manga();
        when(mangaRepository.findById(1L)).thenReturn(Optional.of(manga));
        assertNotNull(mangaService.findOrCreate(1L, null));
    }

    @Test
    void findOrCreate_withMalId_exists() {
        Manga manga = new Manga();
        when(mangaRepository.findByMalId(1)).thenReturn(Optional.of(manga));
        assertNotNull(mangaService.findOrCreate(null, 1));
    }

    @Test
    void findOrCreate_withMalId_create() {
        when(mangaRepository.findByMalId(1)).thenReturn(Optional.empty());
        when(jikanService.getMangaById(1)).thenReturn(new MangaResponseDTO());
        when(mangaRepository.save(any(Manga.class))).thenReturn(new Manga());
        assertNotNull(mangaService.findOrCreate(null, 1));
    }
}