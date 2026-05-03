package com.calonuria.backend.dto.list;

import com.calonuria.backend.dto.catalog.BookResponseDTO;
import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * DTO para la respuesta con información de un item de lista incluyendo su posición.
 */
@Data
public class ListItemResponseDTO {

    private Long id;

    @JsonProperty("item_type")
    private String itemType; // BOOK, MANGA, FANFIC

    private Integer position;

    // Solo uno de estos será no null dependiendo del itemType
    private BookResponseDTO book;
    private MangaResponseDTO manga;
    private FanfictionResponseDTO fanfic;
}
