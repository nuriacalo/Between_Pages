package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

/**
 * DTO para el registro de entradas en el diario de lectura de fanfictions.
 */
@Data
public class FanficJournalRegistrationDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long userId;

    private Long fanfictionId;

    // --- Datos del fanfic (Por si es la primera vez que se añade a la app) ---
    private String ao3Id;
    private String title;
    private String author;
    private String sourceMaterial;
    private String description;
    private String coverUrl;
    private String genre;
    private String theme;
    private Integer totalChapters;
    private String publicationStatus;
    // ------------------------------------------------------------------------

    @NotBlank(message = "El estado es obligatorio")
    @Pattern(regexp = "Pendiente|Leyendo|Terminado|Abandonado",
            message = "Estado no válido")
    private String status;

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer currentChapter;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 5, message = "La valoración máxima es 5")
    private Integer rating;

    private String mainShip;
    private String secondaryShips;
    
    @Pattern(regexp = "NONE|LOW|MEDIUM|HIGH|EXTREME", message = "Nivel de angst no válido")
    private String angstLevel;
    
    private String shipLoyalty;
    
    @Pattern(regexp = "CANON|AU|CANON_DIVERGENT", message = "Valor no válido")
    private String canonType;
    
    private Boolean rereading;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
}