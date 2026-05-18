package com.calonuria.backend.features.catalog.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

/**
 * Entidad que representa un libro en el catálogo central (Media Catalog).
 * Mapea la tabla "book" de la base de datos PostgreSQL.
 * Actúa como la fuente principal de verdad para los metadatos del libro, independientemente
 * de qué usuario lo esté leyendo.
 */
@Entity
@Table(name = "book")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {

    /**
     * Identificador único auto-generado para el libro (Primary Key).
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Identificador único proveniente de la API de Google Books.
     * Utilizado para evitar duplicados al extraer información de la API.
     */
    @Column(name = "google_books_id", unique = true, length = 50)
    private String googleBooksId;

    /**
     * Título principal del libro.
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Autor(es) del libro.
     */
    @Column(nullable = false, length = 255)
    private String author;

    /**
     * Número de ISBN (10 o 13) del libro.
     */
    @Column(length = 20)
    private String isbn;

    /**
     * Nombre de la editorial que publicó el libro.
     */
    @Column(length = 150)
    private String publisher;

    /**
     * Sinopsis o descripción detallada del libro.
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * URL a la imagen de portada del libro (normalmente apuntando a servidores de Google Books).
     */
    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    /**
     * Conjunto de géneros asociados al libro.
     * Mapeado a través de la tabla de unión "book_genre".
     */
    @ManyToMany(fetch = FetchType.LAZY, cascade = { CascadeType.PERSIST, CascadeType.MERGE })
    @JoinTable(name = "book_genre",
            joinColumns = @JoinColumn(name = "book_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private Set<Genre> genres = new HashSet<>();

    /**
     * Formato o tipo de publicación (e.g., STANDALONE, DUOLOGY, TRILOGY, SAGA, SERIES).
     */
    @Column(name = "book_type", length = 50)
    private String bookType;

    /**
     * Año de publicación original del libro.
     */
    @Column(name = "publication_year")
    private Integer publicationYear;

    /**
     * Número total de páginas del libro.
     */
    @Column(name = "page_count")
    private Integer pageCount;
}
