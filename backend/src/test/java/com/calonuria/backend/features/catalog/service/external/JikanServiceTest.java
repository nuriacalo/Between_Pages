package com.calonuria.backend.features.catalog.service.external;

import com.calonuria.backend.features.search.service.JikanService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.client.RestTemplate;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class JikanServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private JikanService jikanService;

    @Test
    void searchManga() {
        when(restTemplate.getForObject(any(java.net.URI.class), eq(String.class))).thenReturn("{\"data\":[]}");
        jikanService.searchManga("test", 1, 10);
    }

    @Test
    void getMangaById() {
        when(restTemplate.getForObject(any(String.class), eq(String.class))).thenReturn("{\"data\":{}}");
        jikanService.getMangaById(1);
    }
}