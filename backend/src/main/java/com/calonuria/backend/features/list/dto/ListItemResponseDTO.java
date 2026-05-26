package com.calonuria.backend.features.list.dto;

import com.calonuria.backend.features.search.dto.BookResponseDTO;
import com.calonuria.backend.features.search.dto.FanfictionResponseDTO;
import com.calonuria.backend.features.search.dto.MangaResponseDTO;
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
