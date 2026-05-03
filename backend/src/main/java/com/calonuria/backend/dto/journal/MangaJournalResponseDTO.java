package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * DTO para la respuesta con información de diario de lectura de mangas.
 */
@Data
public class MangaJournalResponseDTO {

    private Long id;
    private Long userId;
    private MangaResponseDTO manga;
    private String status;
    private Integer currentChapter;
    private Integer currentVolume;
    private Integer rating;
    private Integer tearDrops;
    private Integer spiceFlames;
    private String readingFormat;
    private String favoriteCharacter;
    private String favoriteArc;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime updatedAt;
    private Boolean rereading;
    private String ownership;

    // Campos Módulo 2: Préstamos
    private String loanedTo;
}
