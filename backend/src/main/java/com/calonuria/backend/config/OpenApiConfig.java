package com.calonuria.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

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
