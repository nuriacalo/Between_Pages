package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.MangaResponseDTO;
import com.calonuria.backend.features.catalog.service.MangaService;
import com.calonuria.backend.shared.config.TestSecurityConfig;
import com.calonuria.backend.shared.security.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;
import java.util.Optional;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(MangaController.class)
@Import(TestSecurityConfig.class)
class MangaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MangaService mangaService;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void searchByTitle() throws Exception {
        when(mangaService.searchByTitle("test")).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/manga/search").param("q", "test"))
                .andExpect(status().isOk());
    }

    @Test
    void saveManga() throws Exception {
        MangaResponseDTO dto = new MangaResponseDTO();
        when(mangaService.createManga(dto)).thenReturn(dto);

        mockMvc.perform(post("/api/manga")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());
    }

    @Test
    void updateManga() throws Exception {
        MangaResponseDTO dto = new MangaResponseDTO();
        when(mangaService.updateManga(1L, dto)).thenReturn(Optional.of(dto));

        mockMvc.perform(put("/api/manga/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());
    }
}