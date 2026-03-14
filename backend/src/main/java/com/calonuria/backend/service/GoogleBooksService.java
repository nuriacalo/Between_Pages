package com.calonuria.backend.service;

import com.calonuria.backend.config.GoogleBooksConfig;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class GoogleBooksService {

    private static final Logger log = LoggerFactory.getLogger(GoogleBooksService.class);

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private GoogleBooksConfig config;

    public JsonNode buscarPorTitulo(String titulo) {
        String url = "https://www.googleapis.com/books/v1/volumes?q=intitle:"
                + titulo + "&maxResults=10&key=" + config.getApiKey();
        try {
            String json = restTemplate.getForObject(url, String.class);
            return new ObjectMapper().readTree(json).path("items");
        } catch (Exception e) {
            log.error("Error al conectar con Google Books: {}", e.getMessage());
            return null;
        }
    }

    public JsonNode buscarPorId(String googleBooksId) {
        String url = "https://www.googleapis.com/books/v1/volumes/"
                + googleBooksId + "?key=" + config.getApiKey();
        try {
            String json = restTemplate.getForObject(url, String.class);
            return new ObjectMapper().readTree(json);
        } catch (Exception e) {
            log.error("Error al obtener libro por ID de Google Books: {}", e.getMessage());
            return null;
        }
    }
}