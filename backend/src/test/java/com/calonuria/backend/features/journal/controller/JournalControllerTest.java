package com.calonuria.backend.features.journal.controller;

import com.calonuria.backend.features.journal.dto.BookJournalRegistrationDTO;
import com.calonuria.backend.features.journal.model.JournalType;
import com.calonuria.backend.features.journal.service.JournalService;
import com.calonuria.backend.features.journal.service.JournalServiceFactory;
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

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(JournalController.class)
@Import(TestSecurityConfig.class)
class JournalControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JournalServiceFactory serviceFactory;

    @MockBean
    private JournalService<Object, Object> journalService;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void saveBookProgress() throws Exception {
        when(serviceFactory.getService(JournalType.BOOK)).thenReturn(journalService);
        BookJournalRegistrationDTO dto = new BookJournalRegistrationDTO();

        mockMvc.perform(post("/api/journal/book")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());

        verify(journalService).saveProgress(dto);
    }

    @Test
    void getUserJournal() throws Exception {
        when(serviceFactory.getService(JournalType.BOOK)).thenReturn(journalService);
        when(journalService.getUserJournal(1L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/journal/BOOK/user/1"))
                .andExpect(status().isOk());
    }

    @Test
    void getByStatus() throws Exception {
        when(serviceFactory.getService(JournalType.MANGA)).thenReturn(journalService);
        when(journalService.getByStatus(1L, "READING")).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/journal/MANGA/user/1/status")
                        .param("status", "READING"))
                .andExpect(status().isOk());
    }

    @Test
    void getRereadings() throws Exception {
        when(serviceFactory.getService(JournalType.FANFIC)).thenReturn(journalService);
        when(journalService.getRereadings(1L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/journal/FANFIC/user/1/rereadings"))
                .andExpect(status().isOk());
    }

    @Test
    void deleteJournal() throws Exception {
        when(serviceFactory.getService(JournalType.BOOK)).thenReturn(journalService);

        mockMvc.perform(delete("/api/journal/BOOK/1"))
                .andExpect(status().isNoContent());

        verify(journalService).deleteJournal(1L);
    }
}