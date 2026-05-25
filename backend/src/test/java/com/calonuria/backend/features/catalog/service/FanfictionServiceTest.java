package com.calonuria.backend.features.catalog.service;

import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
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
class FanfictionServiceTest {

    @Mock
    private FanfictionRepository fanfictionRepository;

    @InjectMocks
    private FanfictionService fanfictionService;

    @Test
    void findOrCreate_withFanfictionId() {
        Fanfiction fanfic = new Fanfiction();
        when(fanfictionRepository.findById(1L)).thenReturn(Optional.of(fanfic));
        assertNotNull(fanfictionService.findOrCreate(1L, null));
    }

    @Test
    void findOrCreate_withAo3Id_exists() {
        Fanfiction fanfic = new Fanfiction();
        when(fanfictionRepository.findByAo3Id("testId")).thenReturn(Optional.of(fanfic));
        assertNotNull(fanfictionService.findOrCreate(null, "testId"));
    }

    @Test
    void findOrCreate_withAo3Id_create() {
        when(fanfictionRepository.findByAo3Id("testId")).thenReturn(Optional.empty());
        when(fanfictionRepository.save(any(Fanfiction.class))).thenReturn(new Fanfiction());
        assertNotNull(fanfictionService.findOrCreate(null, "testId"));
    }
}