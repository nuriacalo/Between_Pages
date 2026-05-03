package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.BookResponseDTO;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO para la respuesta con información de diario de lectura de libros.
 */
@Data
public class BookJournalResponseDTO {

    private Long id;
    private Long userId;
    private BookResponseDTO book;
    private String status;
    private Integer currentPage;
    private Integer rating;
    private Integer tearDrops;
    private Integer spiceFlames;
    private String readingFormat;
    private List<String> emotions;
    private String favoriteQuotes;
    private String personalNotes;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDateTime updatedAt;
    private Boolean rereading;
    private String ownership;

    // Campos Módulo 2: Series y Préstamos
    private String seriesName;
    private Double seriesOrder;
    private String loanedTo;
}
