package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.shared.constants.ValidationConstants;
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

    private Long bookId;

    private String googleBooksId;

    @Min(value = 0, message = "La página no puede ser negativa")
    private Integer currentPage;

    @Pattern(regexp = ValidationConstants.BOOK_READING_FORMAT_PATTERN,
            message = ValidationConstants.BOOK_READING_FORMAT_MESSAGE)
    private String readingFormat;

    private List<String> emotions;

    private String favoriteQuotes;

    // Campos Módulo 2: Series y Préstamos
    private String seriesName;

    private Double seriesOrder;

    private String loanedTo;
}
