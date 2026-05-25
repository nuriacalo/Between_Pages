package com.calonuria.backend.features.notes.controller;

import com.calonuria.backend.features.notes.dto.NoteRequestDTO;
import com.calonuria.backend.features.notes.dto.NoteResponseDTO;
import com.calonuria.backend.features.notes.service.NoteService;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.config.TestSecurityConfig;
import com.calonuria.backend.shared.security.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NoteController.class)
@Import(TestSecurityConfig.class)
class NoteControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NoteService noteService;

    @MockBean
    private UserRepository userRepository;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    private User mockUser;
    private NoteRequestDTO requestDTO;
    private NoteResponseDTO responseDTO;

    @BeforeEach
    void setUp() {
        mockUser = new User();
        mockUser.setId(1L);
        mockUser.setEmail("test@example.com");

        requestDTO = new NoteRequestDTO();
        requestDTO.setItemType("BOOK");
        requestDTO.setItemId(1L);
        requestDTO.setNote("Test Note");

        responseDTO = new NoteResponseDTO();
        responseDTO.setId(1L);
        responseDTO.setItemType("BOOK");
        responseDTO.setItemId(1L);
        responseDTO.setNote("Test Note");
    }

    @Test
    @DisplayName("POST /api/notes - Success")
    @WithMockUser(username = "test@example.com")
    void createNote_Success() throws Exception {
        given(userRepository.findByEmail("test@example.com")).willReturn(Optional.of(mockUser));
        given(noteService.createNote(anyLong(), any(NoteRequestDTO.class))).willReturn(responseDTO);

        mockMvc.perform(post("/api/notes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(requestDTO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.note").value("Test Note"));
    }

    @Test
    @DisplayName("GET /api/notes - Success")
    @WithMockUser(username = "test@example.com")
    void getNotes_Success() throws Exception {
        given(userRepository.findByEmail("test@example.com")).willReturn(Optional.of(mockUser));
        given(noteService.getNotesByItem(1L, "BOOK", 1L)).willReturn(Collections.singletonList(responseDTO));

        mockMvc.perform(get("/api/notes")
                        .param("itemType", "BOOK")
                        .param("itemId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1L));
    }

    @Test
    @DisplayName("GET /api/notes/all - Success")
    @WithMockUser(username = "test@example.com")
    void getAllNotes_Success() throws Exception {
        given(userRepository.findByEmail("test@example.com")).willReturn(Optional.of(mockUser));
        given(noteService.getAllUserNotes(1L)).willReturn(Collections.singletonList(responseDTO));

        mockMvc.perform(get("/api/notes/all"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(1L));
    }

    @Test
    @DisplayName("DELETE /api/notes/{noteId} - Success")
    @WithMockUser
    void deleteNote_Success() throws Exception {
        mockMvc.perform(delete("/api/notes/1"))
                .andExpect(status().isNoContent());
    }
}