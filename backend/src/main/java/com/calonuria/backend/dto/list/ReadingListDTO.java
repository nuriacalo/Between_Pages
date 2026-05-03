package com.calonuria.backend.dto.list;

import lombok.Data;

/**
 * DTO para devolver la información básica de una lista.
 */
@Data
public class ReadingListDTO {

    private Long id;
    private String name;
    private String description;
    // Se pueden añadir contadores como "totalItems" más adelante
}