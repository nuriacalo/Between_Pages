package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.shared.constants.ValidationConstants;
import com.fasterxml.jackson.annotation.JsonProperty;
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
    @JsonProperty("user_id")
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
    @JsonProperty("tear_drops")
    private Integer tearDrops;

    @Min(value = 0, message = ValidationConstants.SPICE_FLAMES_MIN)
    @Max(value = 5, message = ValidationConstants.SPICE_FLAMES_MAX)
    @JsonProperty("spice_flames")
    private Integer spiceFlames;

    @JsonProperty("reading_format")
    private String readingFormat;

    @JsonProperty("start_date")
    private LocalDate startDate;

    @JsonProperty("end_date")
    private LocalDate endDate;

    private Boolean rereading;

    @JsonProperty("personal_notes")
    private String personalNotes;

    private String ownership;

    // Campos comunes del item (libro/manga/fanfic)
    private String title;
    private String author;
    private String description;

    @JsonProperty("cover_url")
    private String coverUrl;

    private String genre;
}
