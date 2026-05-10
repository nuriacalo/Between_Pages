package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.features.catalog.dto.FanfictionResponseDTO;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * DTO para la respuesta con información de diario de lectura de fanfictions.
 * Extiende de BaseJournalResponseDTO para campos comunes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class FanficJournalResponseDTO extends BaseJournalResponseDTO {

    private FanfictionResponseDTO fanfic;
    private Integer currentChapter;
    private String mainShip;
    private String secondaryShips;
    private String theme;
    private String angstLevel;
    private String shipLoyalty;
    private String canonType;
}