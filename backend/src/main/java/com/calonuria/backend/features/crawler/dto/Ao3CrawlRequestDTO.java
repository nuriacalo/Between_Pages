package com.calonuria.backend.features.crawler.dto;

import jakarta.validation.constraints.NotBlank;

public record Ao3CrawlRequestDTO(
        @NotBlank(message = "La URL o ID de AO3 no puede estar vacía")
        String ao3Input  // acepta URL completa o solo el ID numérico

) {
}