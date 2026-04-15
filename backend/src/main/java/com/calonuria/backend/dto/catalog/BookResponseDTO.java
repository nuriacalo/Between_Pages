package com.calonuria.backend.dto.catalog;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

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

    private String genre;

    @JsonProperty("book_type")
    private String bookType;

    @JsonProperty("publication_year")
    private Integer publicationYear;
}