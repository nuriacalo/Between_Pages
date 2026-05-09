package com.calonuria.backend.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Configuración para la API de Google Books.
 * Gestiona la clave de API necesaria para las búsquedas.
 */
@Component
@ConfigurationProperties(prefix = "google.books")
public class GoogleBooksConfig {

    private String apiKey;

    /**
     * Obtiene la clave de API de Google Books.
     * @return clave de API
     */
    public String getApiKey() {
        return apiKey;
    }

    /**
     * Establece la clave de API de Google Books.
     * @param apiKey clave de API
     */
    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }
}