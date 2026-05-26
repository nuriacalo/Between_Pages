package com.calonuria.backend.features.search.dto;

import lombok.Data;
import java.util.List;

@Data
public class FanfictionResponseDTO {
    private Long id;
    private String ao3Id;
    private String title;
    private String author;
    private String sourceMaterial;
    private String description;
    private String coverUrl;
    private String mainShip;
    private String theme;
    private List<String> genres;
    private List<String> tags;
    private Integer currentChapter;
    private Integer totalChapters;
    private String publicationStatus;
    private String status;
}
