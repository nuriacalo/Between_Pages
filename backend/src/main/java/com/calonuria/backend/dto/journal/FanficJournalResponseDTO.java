package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import lombok.Data;
import java.time.LocalDate;

/**
 * DTO para la respuesta con información de diario de lectura de fanfictions.
 */
@Data
public class FanficJournalResponseDTO {

    private Long id;
    private FanfictionResponseDTO fanfic;
    private String status;
    private Integer currentChapter;
    private Integer rating;
    private String mainShip;
    private String secondaryShips;
    private String theme;
    private String angstLevel;
    private String shipLoyalty;
    private String canonType;
    private Boolean rereading;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
}