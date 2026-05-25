package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.dto.UserRegistrationDTO;
import com.calonuria.backend.features.user.dto.UserResponseDTO;
import com.calonuria.backend.features.user.service.UserService;
import com.calonuria.backend.shared.config.TestSecurityConfig;
import com.calonuria.backend.shared.security.CustomUserDetailsService;
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
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
@Import(TestSecurityConfig.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private JwtUtil jwtUtil;

    @MockBean
    private CustomUserDetailsService customUserDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    private UserRegistrationDTO registrationDTO;
    private UserResponseDTO responseDTO;

    @BeforeEach
    void setUp() {
        registrationDTO = new UserRegistrationDTO();
        registrationDTO.setName("Test User");
        registrationDTO.setEmail("test@example.com");
        registrationDTO.setPassword("password");

        responseDTO = new UserResponseDTO(1L, "Test User", "test@example.com", "USER");
    }

    @Test
    @DisplayName("POST /api/user/register - Success")
    void registerUser_Success() throws Exception {
        given(userService.registerUser(any(UserRegistrationDTO.class))).willReturn(responseDTO);

        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registrationDTO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1L))
                .andExpect(jsonPath("$.name").value("Test User"));
    }

    @Test
    @DisplayName("POST /api/user/register - Email Already Exists")
    void registerUser_EmailExists() throws Exception {
        given(userService.registerUser(any(UserRegistrationDTO.class))).willThrow(new RuntimeException("Email ya existente"));

        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registrationDTO)))
                .andExpect(status().isBadRequest())
                .andExpect(content().string("Email ya existente"));
    }



    @Test
    @DisplayName("GET /api/user/{id} - Not Found")
    void getUser_NotFound() throws Exception {
        given(userService.getUserById(1L)).willReturn(Optional.empty());

        mockMvc.perform(get("/api/user/1"))
                .andExpect(status().isNotFound());
    }
}