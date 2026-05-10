package com.calonuria.backend.features.journal.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Clase base abstracta para DTOs de respuesta de diario de lectura.
 * Contiene los campos comunes compartidos entre libros, mangas y fanfictions.
 */
@Data
public abstract class BaseJournalResponseDTO {

    private Long id;
    private Long userId;
    private String status;
    private Integer rating;
    private Integer tearDrops;
    private Integer spiceFlames;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime updatedAt;
    private Boolean rereading;
    private String readingFormat;
    private String ownership;
    private String loanedTo;
}
