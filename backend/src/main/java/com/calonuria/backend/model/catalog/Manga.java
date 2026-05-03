package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa un manga en el catálogo.
 * Mapea la tabla "manga" de la base de datos.
 */
@Entity
@Table(name = "manga")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Manga {

    /**
     * Identificador único del manga.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Identificador del manga en MyAnimeList.
     */
    @Column(name = "mal_id", unique = true)
    private Integer malId;

    /**
     * Fuente del manga (ej. MangaDex).
     */
    @Column(length = 50)
    private String source;

    /**
     * Título del manga.
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Autor del manga.
     */
    @Column(nullable = false, length = 255)
    private String author;

    /**
     * Demografía objetivo del manga.
     */
    @Column(length = 50)
    private String demographic;

    /**
     * Género del manga.
     */
    @Column(length = 100)
    private String genre;

    /**
     * Descripción del manga.
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * URL de la portada del manga.
     */
    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    /**
     * Total de capítulos del manga.
     */
    @Column(name = "total_chapters")
    private Integer totalChapters;

    /**
     * Total de volúmenes del manga.
     */
    @Column(name = "total_volumes")
    private Integer totalVolumes;

    /**
     * Estado de publicación.
     */
    @Column(name = "publication_status", length = 50)
    private String publicationStatus;

    /**
     * Puntuación de MyAnimeList.
     */
    @Column(name = "mal_score", precision = 4, scale = 2)
    private java.math.BigDecimal malScore;
}