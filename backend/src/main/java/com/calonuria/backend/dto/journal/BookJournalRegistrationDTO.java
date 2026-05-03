package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

/**
 * DTO para el registro de entradas en el diario de lectura de libros.
 */
@Data
public class BookJournalRegistrationDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long userId;

    // Se elimina @NotNull para permitir guardar con los datos de Google Books directamente
    private Long bookId;

    // --- Datos del libro (Por si es la primera vez que se añade a la app) ---
    private String googleBooksId;
    private String title;
    private String author;
    private String isbn;
    private String publisher;
    private String description;
    private String coverUrl;
    private String genre;
    private String bookType;
    private Integer publicationYear;
    // ------------------------------------------------------------------------

    @NotBlank(message = "El estado es obligatorio")
    @Pattern(regexp = "PENDING|READING|FINISHED|DROPPED|PAUSED|TBR|WISHLIST|BOUGHT",
            message = "Estado no válido")
    private String status;

    @Min(value = 0, message = "La página no puede ser negativa")
    private Integer currentPage;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 10, message = "La valoración máxima es 10")
    private Integer rating;

    @Min(value = 0, message = "Mínimo 0 lágrimas")
    @Max(value = 5, message = "Máximo 5 lágrimas")
    private Integer tearDrops;

    @Min(value = 0, message = "Mínimo 0 flames")
    @Max(value = 5, message = "Máximo 5 flames")
    private Integer spiceFlames;

    @Pattern(regexp = "PHYSICAL|DIGITAL|AUDIOBOOK",
            message = "Formato no válido")
    private String readingFormat;

    private List<String> emotions;
    private String favoriteQuotes;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean rereading;

    @Pattern(regexp = "DIGITAL|PHYSICAL|NONE|BORROWED", message = "Propiedad no válida")
    private String ownership;

    // Campos Módulo 2: Series y Préstamos
    private String seriesName;
    private Double seriesOrder; // Double para permitir "Libro 1.5"
    
    private String loanedTo; // A quién se le ha prestado el libro
}
