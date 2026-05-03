package com.calonuria.backend.dto.list;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

/**
 * DTO para la respuesta con detalle de una lista de lectura incluyendo sus elementos.
 * Los items incluyen su posición para permitir ordenamiento personalizado.
 */
@Data
@AllArgsConstructor
public class ReadingListDetailResponseDTO {

    private Long id;
    private String name;
    private String description;

    /**
     * Lista de items ordenados por posición.
     * Cada item incluye su tipo y la información del contenido (book, manga o fanfic).
     */
    private List<ListItemResponseDTO> items;
}