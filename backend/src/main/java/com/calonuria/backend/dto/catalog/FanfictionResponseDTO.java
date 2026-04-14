package com.calonuria.backend.dto.catalog;

import lombok.Data;
import java.util.List;

/**
 * DTO para la respuesta con información de fanfiction.
 */
@Data
public class FanfictionResponseDTO {

    private Long id;
    private String ao3Id;
    private String title;
    private String author;
    private String sourceMaterial;
    private String description;
    private String coverUrl;
    private String genre;
    private String mainShip;
    private String theme;
    private Integer currentChapter;
    private Integer totalChapters;
    private String publicationStatus;
    private List<String> tags;
}