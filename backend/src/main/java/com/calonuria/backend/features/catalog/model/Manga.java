package com.calonuria.backend.features.catalog.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

/**
 * Entidad que representa un manga en el catálogo central (Media Catalog).
 * Mapea la tabla "manga" de la base de datos PostgreSQL.
 * Almacena información consolidada de MyAnimeList u otras fuentes para unificarla
 * entre todos los usuarios de la aplicación.
 */
@Entity
@Table(name = "manga")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Manga {

    /**
     * Identificador único auto-generado para el manga (Primary Key).
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Identificador único oficial de MyAnimeList.
     * Esencial para sincronizaciones futuras con la API Jikan.
     */
    @Column(name = "mal_id", unique = true)
    private Integer malId;

    /**
     * Fuente de los datos (por defecto 'MyAnimeList').
     */
    @Column(length = 50)
    private String source;

    /**
     * Título principal del manga (romanizado o en inglés).
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Autor(es) o mangaka del manga.
     */
    @Column(nullable = false, length = 255)
    private String author;

    /**
     * Demografía objetivo del manga (e.g., Shounen, Seinen, Shoujo).
     */
    @Column(length = 50)
    private String demographic;

    /**
     * Conjunto de géneros asociados al manga.
     * Mapeado a través de la tabla de unión "manga_genre".
     */
    @ManyToMany(fetch = FetchType.EAGER, cascade = { CascadeType.PERSIST, CascadeType.MERGE })
    @JoinTable(name = "manga_genre",
            joinColumns = @JoinColumn(name = "manga_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private Set<Genre> genres = new HashSet<>();

    /**
     * Sinopsis de la trama del manga.
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * URL a la imagen de portada oficial proporcionada por MyAnimeList.
     */
    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    /**
     * Número total de capítulos. Puede ser nulo si está en emisión (Publishing).
     */
    @Column(name = "total_chapters")
    private Integer totalChapters;

    /**
     * Número total de volúmenes impresos.
     */
    @Column(name = "total_volumes")
    private Integer totalVolumes;

    /**
     * Estado oficial de publicación (e.g., Publishing, Finished, On Hiatus).
     */
    @Column(name = "publication_status", length = 50)
    private String publicationStatus;

    /**
     * Puntuación promedio asignada por los usuarios de MyAnimeList (1.00 a 10.00).
     */
    @Column(name = "mal_score", precision = 4, scale = 2)
    private java.math.BigDecimal malScore;
}