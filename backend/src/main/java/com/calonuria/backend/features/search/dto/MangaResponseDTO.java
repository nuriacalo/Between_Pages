package com.calonuria.backend.features.search.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/**
 * DTO para la respuesta con información de manga.
 */
@Data
public class MangaResponseDTO {

    private Long id;

    @JsonProperty("mal_id")
    private Integer malId;

    @JsonProperty("mal_score")
    private java.math.BigDecimal malScore;

    private String source;
    private String title;
    private String author;
    private String demographic;
    private List<String> genres;
    private String description;

    @JsonProperty("cover_url")
    private String coverUrl;

    @JsonProperty("total_chapters")
    private Integer totalChapters;

    @JsonProperty("total_volumes")
    private Integer totalVolumes;

    @JsonProperty("publication_status")
    private String publicationStatus;

    private String status;
}
