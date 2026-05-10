package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.shared.constants.ValidationConstants;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * DTO para el registro de entradas en el diario de lectura de mangas.
 * Extiende de BaseJournalRegistrationDTO para campos comunes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class MangaJournalRegistrationDTO extends BaseJournalRegistrationDTO {

    private Long mangaId;

    // --- Datos específicos del manga ---
    private Integer malId;
    private String source;
    private String demographic;
    private Integer totalChapters;
    private Integer totalVolumes;
    private String publicationStatus;
    // -----------------------------------

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer currentChapter;

    @Min(value = 0, message = "El volumen no puede ser negativo")
    private Integer currentVolume;

    @Pattern(regexp = ValidationConstants.MANGA_READING_FORMAT_PATTERN,
            message = ValidationConstants.MANGA_READING_FORMAT_MESSAGE)
    private String readingFormat;

    private String favoriteCharacter;
    private String favoriteArc;

    // Campos Módulo 2: Préstamos
    private String loanedTo;
}
