package com.calonuria.backend.features.catalog.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

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

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "mal_id", unique = true)
    private Integer malId;

    @Column(length = 50)
    private String source;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(nullable = false, length = 255)
    private String author;

    @Column(length = 50)
    private String demographic;

    @ManyToMany(fetch = FetchType.LAZY, cascade = { CascadeType.PERSIST, CascadeType.MERGE })
    @JoinTable(name = "manga_genre",
            joinColumns = @JoinColumn(name = "manga_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private Set<Genre> genres = new HashSet<>();

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    @Column(name = "total_chapters")
    private Integer totalChapters;

    @Column(name = "total_volumes")
    private Integer totalVolumes;

    @Column(name = "publication_status", length = 50)
    private String publicationStatus;

    @Column(name = "mal_score", precision = 4, scale = 2)
    private java.math.BigDecimal malScore;
}
