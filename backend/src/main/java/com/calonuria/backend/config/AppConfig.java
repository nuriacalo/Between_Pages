package com.calonuria.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

/**
 * Configuración general de la aplicación.
 * Define beans de utilidad como RestTemplate para llamadas HTTP.
 */
@Configuration
public class AppConfig {

    /**
     * Crea un bean RestTemplate para realizar llamadas HTTP a APIs externas.
     * @return instancia de RestTemplate
     */
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
