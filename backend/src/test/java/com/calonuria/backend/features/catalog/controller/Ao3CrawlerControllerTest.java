package com.calonuria.backend.features.catalog.controller;

import com.calonuria.backend.features.search.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.service.FanficService;
import com.calonuria.backend.features.crawler.controller.Ao3CrawlerController;
import com.calonuria.backend.features.crawler.dto.Ao3CrawlRequestDTO;
import com.calonuria.backend.features.crawler.service.Ao3CrawlerService;
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

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(Ao3CrawlerController.class)
@Import(TestSecurityConfig.class)
class Ao3CrawlerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private Ao3CrawlerService ao3CrawlerService;

    @MockBean
    private FanficService fanficService;

    @MockBean
    private JwtUtil jwtUtil;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void crawlWork() throws Exception {
        Ao3CrawlRequestDTO request = new Ao3CrawlRequestDTO("12345");

        Fanfiction fanfic = new Fanfiction();
        FanfictionResponseDTO response = new FanfictionResponseDTO();

        when(ao3CrawlerService.crawlWork("12345")).thenReturn(fanfic);
        when(fanficService.mapToDTO(fanfic)).thenReturn(response);

        mockMvc.perform(post("/api/crawler/ao3")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());
    }
}