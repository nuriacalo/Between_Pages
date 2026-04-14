package com.calonuria.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuración de OpenAPI/Swagger para la documentación de la API.
 */
@Configuration
public class OpenApiConfig {

    /**
     * Configura la información personalizada de la API para Swagger.
     * @return configuración personalizada de OpenAPI
     */
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("API Backend - BetweenPages")
                        .version("1.0")
                        .description("Documentación de la API REST para la gestión de catálogos y diarios de lectura (Libros, Mangas, Fanfics).")
                        .contact(new Contact()
                                .name("Nuria Calo")
                                .email("nuria@example.com") // Puedes cambiarlo si quieres
                        ));
    }
}
