package com.calonuria.backend.features.catalog.controller;


import com.calonuria.backend.features.search.controller.ExternalMangaController;
import com.calonuria.backend.features.search.service.JikanService;
import com.calonuria.backend.shared.config.TestSecurityConfig;
import com.calonuria.backend.shared.security.JwtUtil;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ExternalMangaController.class)
@Import(TestSecurityConfig.class)
class ExternalMangaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JikanService jikanService;

    @MockBean
    private JwtUtil jwtUtil;

    @Test
    void searchManga() throws Exception {
        when(jikanService.searchManga("test", 1, 10)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/external/manga/search")
                        .param("q", "test")
                        .param("page", "1")
                        .param("limit", "10"))
                .andExpect(status().isOk());
    }

    @Test
    void getMangaById() throws Exception {
        when(jikanService.getMangaById(1)).thenReturn(null);

        mockMvc.perform(get("/api/external/manga/1"))
                .andExpect(status().isNotFound());
    }
}