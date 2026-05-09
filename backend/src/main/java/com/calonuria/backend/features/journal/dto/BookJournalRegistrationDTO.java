package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.ValidationConstants;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import java.util.List;

/**
 * DTO para el registro de entradas en el diario de lectura de libros.
 * Extiende de BaseJournalRegistrationDTO para campos comunes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class BookJournalRegistrationDTO extends BaseJournalRegistrationDTO {

    @JsonProperty("book_id")
    private Long bookId;

    @JsonProperty("google_books_id")
    private String googleBooksId;

    @Min(value = 0, message = "La página no puede ser negativa")
    @JsonProperty("current_page")
    private Integer currentPage;

    @Pattern(regexp = ValidationConstants.BOOK_READING_FORMAT_PATTERN,
            message = ValidationConstants.BOOK_READING_FORMAT_MESSAGE)
    private String readingFormat;

    private List<String> emotions;

    @JsonProperty("favorite_quotes")
    private String favoriteQuotes;

    // Campos Módulo 2: Series y Préstamos
    @JsonProperty("series_name")
    private String seriesName;

    @JsonProperty("series_order")
    private Double seriesOrder;

    @JsonProperty("loaned_to")
    private String loanedTo;
}
