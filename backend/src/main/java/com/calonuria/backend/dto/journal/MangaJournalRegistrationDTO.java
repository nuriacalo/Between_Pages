package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

/**
 * DTO para el registro de entradas en el diario de lectura de mangas.
 */
@Data
public class MangaJournalRegistrationDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long userId;

    private Long mangaId;

    // --- Datos del manga (Por si es la primera vez que se añade a la app) ---
    private String mangadexId;
    private String source;
    private String title;
    private String author;
    private String demographic;
    private String genre;
    private String description;
    private String coverUrl;
    private Integer totalChapters;
    private Integer totalVolumes;
    private String publicationStatus;
    // ------------------------------------------------------------------------

    @NotBlank(message = "El estado es obligatorio")
    @Pattern(regexp = "Pendiente|Leyendo|Terminado|Abandonado",
            message = "Estado no válido")
    private String status;

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer currentChapter;

    @Min(value = 0, message = "El volumen no puede ser negativo")
    private Integer currentVolume;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 5, message = "La valoración máxima es 5")
    private Integer rating;

    @Pattern(regexp = "Fisico|Digital",
            message = "Formato no válido")
    private String readingFormat;

    private String favoriteCharacter;
    private String favoriteArc;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean rereading;
}
