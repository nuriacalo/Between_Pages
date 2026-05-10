package com.calonuria.backend.features.catalog.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/**
 * DTO para la respuesta con información de libro.
 */
@Data
public class BookResponseDTO {

    private Long id;

    @JsonProperty("google_books_id")
    private String googleBooksId;

    private String title;
    private String author;
    private String isbn;
    private String publisher;
    private String description;

    @JsonProperty("cover_url")
    private String coverUrl;

    private List<String> genres; // Changed from String genre to List<String> genres

    @JsonProperty("book_type")
    private String bookType;

    @JsonProperty("publication_year")
    private Integer publicationYear;

    @JsonProperty("page_count")
    private Integer pageCount;
}
