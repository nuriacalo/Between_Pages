package com.calonuria.backend.features.list.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddContentToListRequestDTO {

    @NotNull(message = "El ID del contenido es obligatorio")
    private Long contentId;

    @NotBlank(message = "El tipo de contenido es obligatorio")
    private String contentType; // "BOOK", "MANGA", "FANFIC"
}