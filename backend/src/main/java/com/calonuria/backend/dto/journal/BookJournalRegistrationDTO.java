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
    @Pattern(regexp = "Pendiente|Leyendo|Terminado|Abandonado",
            message = "Estado no válido")
    private String status;

    @Min(value = 0, message = "La página no puede ser negativa")
    private Integer currentPage;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 5, message = "La valoración máxima es 5")
    private Integer rating;

    @Pattern(regexp = "Fisico|Digital|Audiolibro",
            message = "Formato no válido")
    private String readingFormat;

    private List<String> emotions;
    private String favoriteQuotes;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean rereading;
}
