package com.calonuria.backend.features.catalog.service.external;

import com.calonuria.backend.features.search.service.GoogleBooksService;
import com.calonuria.backend.shared.config.GoogleBooksConfig;
import com.fasterxml.jackson.databind.ObjectMapper;
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
class GoogleBooksServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @Mock
    private GoogleBooksConfig googleBooksConfig;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private GoogleBooksService googleBooksService;

    @Test
    void searchBooks() throws Exception {
        when(googleBooksConfig.getApiKey()).thenReturn("testKey");
        when(restTemplate.getForObject(any(java.net.URI.class), eq(String.class))).thenReturn("{}");
        when(objectMapper.readTree("{}")).thenReturn(new ObjectMapper().createObjectNode());

        googleBooksService.searchBooks("test");
    }

    @Test
    void fetchBookByGoogleId() throws Exception {
        when(googleBooksConfig.getApiKey()).thenReturn("testKey");
        when(restTemplate.getForObject(any(java.net.URI.class), eq(String.class))).thenReturn("{}");
        when(objectMapper.readTree("{}")).thenReturn(new ObjectMapper().createObjectNode());

        googleBooksService.fetchBookByGoogleId("testId");
    }
}