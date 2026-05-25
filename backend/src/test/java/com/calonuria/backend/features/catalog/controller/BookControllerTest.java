package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.dto.BookResponseDTO;
import com.calonuria.backend.features.catalog.service.BookService;
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

@WebMvcTest(BookController.class)
@Import(TestSecurityConfig.class)
class BookControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private BookService bookService;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void searchByTitle() throws Exception {
        when(bookService.searchByTitle("test")).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/book/search").param("q", "test"))
                .andExpect(status().isOk());
    }

    @Test
    void saveBook() throws Exception {
        BookResponseDTO dto = new BookResponseDTO();
        when(bookService.createBook(dto)).thenReturn(dto);

        mockMvc.perform(post("/api/book")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());
    }

    @Test
    void updateBook() throws Exception {
        BookResponseDTO dto = new BookResponseDTO();
        when(bookService.updateBook(1L, dto)).thenReturn(Optional.of(dto));

        mockMvc.perform(put("/api/book/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());
    }
}