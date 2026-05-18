package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.shared.constants.ValidationConstants;
import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

/**
 * Clase base abstracta para DTOs de registro de entradas en el diario de lectura.
 * Contiene los campos comunes compartidos entre libros, mangas y fanfictions.
 * Las subclases pueden sobrescribir validaciones específicas si es necesario.
 */
@Data
public abstract class BaseJournalRegistrationDTO {

    @NotNull(message = ValidationConstants.USER_ID_REQUIRED)
    private Long userId;

    @NotBlank(message = ValidationConstants.STATUS_REQUIRED)
    @Pattern(regexp = ValidationConstants.READING_STATUS_PATTERN,
            message = ValidationConstants.READING_STATUS_MESSAGE)
    private String status;

    @Min(value = 1, message = ValidationConstants.RATING_MIN)
    @Max(value = 10, message = ValidationConstants.RATING_MAX)
    private Integer rating;

    @Min(value = 0, message = ValidationConstants.TEAR_DROPS_MIN)
    @Max(value = 5, message = ValidationConstants.TEAR_DROPS_MAX)
    private Integer tearDrops;

    @Min(value = 0, message = ValidationConstants.SPICE_FLAMES_MIN)
    @Max(value = 5, message = ValidationConstants.SPICE_FLAMES_MAX)
    private Integer spiceFlames;

    private String readingFormat;

    private LocalDate startDate;

    private LocalDate endDate;

    private Boolean rereading;

    private String personalNotes;

    private String ownership;

    // Campos comunes del item (libro/manga/fanfic)
    private String title;
    private String author;
    private String description;

    private String coverUrl;

    private String genre;
}
