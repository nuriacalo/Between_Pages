package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.service.FanfictionService;
import com.calonuria.backend.features.search.dto.FanfictionResponseDTO;
import com.calonuria.backend.shared.config.TestSecurityConfig;
import com.calonuria.backend.shared.security.CustomUserDetailsService;
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

@WebMvcTest(FanfictionController.class)
@Import(TestSecurityConfig.class)
class FanfictionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private FanfictionService fanfictionService;

    @MockBean
    private JwtUtil jwtUtil;

    @MockBean
    private CustomUserDetailsService customUserDetailsService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void searchByStatus() throws Exception {
        when(fanfictionService.searchByStatus("ONGOING")).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/fanfiction/status").param("status", "ONGOING"))
                .andExpect(status().isOk());
    }

    @Test
    void saveFanfic() throws Exception {
        FanfictionResponseDTO dto = new FanfictionResponseDTO();
        when(fanfictionService.createFanfic(dto)).thenReturn(dto);

        mockMvc.perform(post("/api/fanfiction")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());
    }

    @Test
    void updateFanfic() throws Exception {
        FanfictionResponseDTO dto = new FanfictionResponseDTO();
        when(fanfictionService.updateFanfic(1L, dto)).thenReturn(Optional.of(dto));

        mockMvc.perform(put("/api/fanfiction/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk());
    }
}