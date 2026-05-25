package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.catalog.service.FanficTagService;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(FanficTagController.class)
@Import(TestSecurityConfig.class)
class FanficTagControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private FanficTagService fanficTagService;

    @MockBean
    private JwtUtil jwtUtil;

    @Test
    void getTags() throws Exception {
        when(fanficTagService.getTagsByFanfic(1L)).thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/fanfiction/1/tags"))
                .andExpect(status().isOk());
    }

    @Test
    void addTag() throws Exception {
        when(fanficTagService.addTag(1L, "test")).thenReturn("test");

        mockMvc.perform(post("/api/fanfiction/1/tags").param("tag", "test"))
                .andExpect(status().isOk());
    }

    @Test
    void deleteTag() throws Exception {
        mockMvc.perform(delete("/api/fanfiction/1/tags/1"))
                .andExpect(status().isNoContent());
    }
}