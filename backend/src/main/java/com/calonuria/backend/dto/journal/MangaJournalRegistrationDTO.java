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
    private Integer malId;
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
    @Pattern(regexp = "PENDING|READING|FINISHED|DROPPED|PAUSED|TBR|WISHLIST|BOUGHT",
            message = "Estado no válido")
    private String status;

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer currentChapter;

    @Min(value = 0, message = "El volumen no puede ser negativo")
    private Integer currentVolume;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 10, message = "La valoración máxima es 10")
    private Integer rating;

    @Min(value = 0, message = "Mínimo 0 lágrimas")
    @Max(value = 5, message = "Máximo 5 lágrimas")
    private Integer tearDrops;

    @Min(value = 0, message = "Mínimo 0 flames")
    @Max(value = 5, message = "Máximo 5 flames")
    private Integer spiceFlames;

    @Pattern(regexp = "PHYSICAL|DIGITAL",
            message = "Formato no válido")
    private String readingFormat;

    private String favoriteCharacter;
    private String favoriteArc;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private Boolean rereading;

    @Pattern(regexp = "DIGITAL|PHYSICAL|NONE|BORROWED", message = "Propiedad no válida")
    private String ownership;

    // Campos Módulo 2: Préstamos
    private String loanedTo;
}
