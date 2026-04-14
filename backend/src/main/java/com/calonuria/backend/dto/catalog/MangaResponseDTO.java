package com.calonuria.backend.dto.catalog;

import lombok.Data;

/**
 * DTO para la respuesta con información de manga.
 */
@Data
public class MangaResponseDTO {

    private Long id;
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
}