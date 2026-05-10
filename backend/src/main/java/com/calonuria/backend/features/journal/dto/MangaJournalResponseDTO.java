package com.calonuria.backend.features.journal.dto;

import com.calonuria.backend.features.catalog.dto.MangaResponseDTO;
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
    private String favoriteCharacter;
    private String favoriteArc;
}
