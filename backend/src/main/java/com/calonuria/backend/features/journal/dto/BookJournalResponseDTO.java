package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.features.search.dto.BookResponseDTO;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.util.List;

/**
 * DTO para la respuesta con información de diario de lectura de libros.
 * Extiende de BaseJournalResponseDTO para campos comunes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class BookJournalResponseDTO extends BaseJournalResponseDTO {

    private BookResponseDTO book;
    private Integer currentPage;
    private List<String> emotions;
    private String favoriteQuotes;

    // Campos Módulo 2: Series
    private String seriesName;
    private Double seriesOrder;
}
