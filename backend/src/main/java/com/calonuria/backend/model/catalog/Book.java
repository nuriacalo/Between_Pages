package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa un libro en el catálogo.
 * Mapea la tabla "book" de la base de datos.
 */
@Entity
@Table(name = "book")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {

    /**
     * Identificador único del libro.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Identificador del libro en Google Books API.
     */
    @Column(name = "google_books_id", unique = true, length = 50)
    private String googleBooksId;

    /**
     * Título del libro.
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Autor del libro.
     */
    @Column(nullable = false, length = 255)
    private String author;

    /**
     * ISBN del libro.
     */
    @Column(length = 20)
    private String isbn;

    /**
     * Editorial del libro.
     */
    @Column(length = 150)
    private String publisher;

    /**
     * Descripción del libro.
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * URL de la portada del libro.
     */
    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    /**
     * Género del libro.
     */
    @Column(length = 100)
    private String genre;

    /**
     * Tipo de libro: STANDALONE, DUOLOGY, TRILOGY, SAGA, SERIES.
     */
    @Column(name = "book_type", length = 50)
    private String bookType;

    /**
     * Año de publicación del libro.
     */
    @Column(name = "publication_year")
    private Integer publicationYear;
}
