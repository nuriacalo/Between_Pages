package com.calonuria.backend.dto.catalog;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

/**
 * DTO para la respuesta con información de fanfiction.
 */
@Data
public class FanfictionResponseDTO {

    private Long id;

    @JsonProperty("ao3_id")
    private String ao3Id;

    private String title;
    private String author;

    @JsonProperty("source_material")
    private String sourceMaterial;

    private String description;

    @JsonProperty("cover_url")
    private String coverUrl;

    private String genre;

    @JsonProperty("main_ship")
    private String mainShip;

    private String theme;

    @JsonProperty("current_chapter")
    private Integer currentChapter;

    @JsonProperty("total_chapters")
    private Integer totalChapters;

    @JsonProperty("publication_status")
    private String publicationStatus;

    private List<String> tags;
}