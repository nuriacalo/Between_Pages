package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.service.external.GoogleBooksService;
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

@WebMvcTest(ExternalBookController.class)
@Import(TestSecurityConfig.class)
class ExternalBookControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private GoogleBooksService googleBooksService;

    @MockBean
    private JwtUtil jwtUtil;

    @Test
    void searchBooks() throws Exception {
        when(googleBooksService.searchBooks("test")).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/external/book/search").param("q", "test"))
                .andExpect(status().isOk());
    }

    @Test
    void searchBooks_emptyQuery() throws Exception {
        mockMvc.perform(get("/api/external/book/search").param("q", " "))
                .andExpect(status().isBadRequest());
    }
}