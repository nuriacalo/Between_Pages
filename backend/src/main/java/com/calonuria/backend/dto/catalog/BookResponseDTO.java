package com.calonuria.backend.dto.catalog;

import lombok.Data;

/**
 * DTO para la respuesta con información de libro.
 */
@Data
public class BookResponseDTO {

    private Long id;
    private String googleBooksId;
    private String title;
    private String author;
    private String isbn;
    private String publisher;
    private String description;
    private String coverUrl;
    private String genre;
    private String bookType;
    private Integer publicationYear;
}