package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.shared.constants.ValidationConstants;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * DTO para el registro de entradas en el diario de lectura de fanfictions.
 * Extiende de BaseJournalRegistrationDTO para campos comunes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class FanficJournalRegistrationDTO extends BaseJournalRegistrationDTO {

    @JsonProperty("fanficId")
    private Long fanfictionId;

    // --- Datos específicos del fanfic ---
    private String ao3Id;
    private String title;
    private String author;
    private String sourceMaterial;
    private String theme;
    private Integer totalChapters;
    private String publicationStatus;
    // ------------------------------------

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer currentChapter;

    private String mainShip;
    private String secondaryShips;

    @Pattern(regexp = ValidationConstants.ANGST_LEVEL_PATTERN,
            message = ValidationConstants.ANGST_LEVEL_MESSAGE)
    private String angstLevel;

    private String shipLoyalty;

    @Pattern(regexp = ValidationConstants.CANON_TYPE_PATTERN,
            message = ValidationConstants.CANON_TYPE_MESSAGE)
    private String canonType;
}
