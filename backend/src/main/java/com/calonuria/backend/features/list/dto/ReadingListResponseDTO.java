package com.calonuria.backend.dto.list;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * DTO para la respuesta con información de listas de lectura.
 */
@Data
@AllArgsConstructor
public class ReadingListResponseDTO {

    private Long id;
    private String name;
    private String description;
}
