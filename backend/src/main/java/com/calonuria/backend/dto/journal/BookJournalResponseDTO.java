package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.BookResponseDTO;
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
    private String readingFormat;
    private List<String> emotions;
    private String favoriteQuotes;
    private String ownership;

    // Campos Módulo 2: Series y Préstamos
    private String seriesName;
    private Double seriesOrder;
    private String loanedTo;
}
