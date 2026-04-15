package com.calonuria.backend.dto.catalog;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * DTO para la respuesta con información de manga.
 */
@Data
public class MangaResponseDTO {

    private Long id;

    @JsonProperty("mangadex_id")
    private String mangadexId;

    private String source;
    private String title;
    private String author;
    private String demographic;
    private String genre;
    private String description;

    @JsonProperty("cover_url")
    private String coverUrl;

    @JsonProperty("total_chapters")
    private Integer totalChapters;

    @JsonProperty("total_volumes")
    private Integer totalVolumes;

    @JsonProperty("publication_status")
    private String publicationStatus;
}