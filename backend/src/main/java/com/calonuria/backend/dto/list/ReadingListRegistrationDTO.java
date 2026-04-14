package com.calonuria.backend.dto.list;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * DTO para el registro de listas de lectura.
 */
@Data
public class ReadingListRegistrationDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long userId;

    @NotBlank(message = "El nombre es obligatorio")
    private String name;

    private String description;
}
