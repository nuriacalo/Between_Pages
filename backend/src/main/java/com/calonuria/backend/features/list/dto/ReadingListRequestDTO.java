package com.calonuria.backend.features.list.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO para la creación y edición de listas de lectura.
 */
@Data
public class ReadingListRequestDTO {

    @NotBlank(message = "El nombre de la lista es obligatorio")
    private String name;
    private String description;
}