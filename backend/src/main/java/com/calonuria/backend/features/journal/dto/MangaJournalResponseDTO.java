package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * DTO para la respuesta con información de diario de lectura de mangas.
 * Extiende de BaseJournalResponseDTO para campos comunes.
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class MangaJournalResponseDTO extends BaseJournalResponseDTO {

    private MangaResponseDTO manga;
    private Integer currentChapter;
    private Integer currentVolume;
    private String readingFormat;
    private String favoriteCharacter;
    private String favoriteArc;
    private String ownership;

    // Campos Módulo 2: Préstamos
    private String loanedTo;
}
