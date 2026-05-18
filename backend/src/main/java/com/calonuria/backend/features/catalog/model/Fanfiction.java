package com.calonuria.backend.features.catalog.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.BatchSize;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Entidad que representa un fanfiction en el catálogo central (Media Catalog).
 * Mapea la tabla "fanfiction" de la base de datos PostgreSQL.
 * Almacena metadatos críticos extraídos normalmente a través del crawler de
 * Archive of Our Own (AO3) y los comparte con todos los usuarios.
 */
@Entity
@Table(name = "fanfiction")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Fanfiction {

    /**
     * Identificador único auto-generado para el fanfic (Primary Key).
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Identificador único oficial de la obra en Archive of Our Own (AO3).
     * Es la parte numérica de la URL "https://archiveofourown.org/works/12345".
     */
    @Column(name = "ao3_id", unique = true, length = 50, nullable = true)
    private String ao3Id;

    /**
     * Título principal del fanfiction.
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Autor del fanfiction (en AO3 también llamado 'Creator').
     */
    @Column(nullable = false, length = 255)
    private String author;

    /**
     * Fandom original o material fuente en el que se basa la obra (e.g., Harry Potter, MCU).
     */
    @Column(name = "source_material", length = 255)
    private String sourceMaterial;

    /**
     * Resumen provisto por el autor (Summary).
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * Opcional: URL a una imagen si el fanfiction cuenta con una portada personalizada.
     */
    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    /**
     * Conjunto de géneros de alto nivel asociados al fanfiction.
     */
    @ManyToMany(fetch = FetchType.LAZY, cascade = { CascadeType.PERSIST, CascadeType.MERGE })
    @JoinTable(name = "fanfiction_genre",
            joinColumns = @JoinColumn(name = "fanfic_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private Set<Genre> genres = new HashSet<>();

    /**
     * Relación o 'Ship' principal de la obra.
     */
    @Column(name = "main_ship", length = 150)
    private String mainShip;

    /**
     * Temática dominante de la historia.
     */
    @Column(length = 150)
    private String theme;

    /**
     * Último capítulo publicado por el autor (o actual si está pausado).
     */
    @Column(name = "current_chapter")
    private Integer currentChapter = 0;

    /**
     * Número total estimado de capítulos para la obra.
     * Puede ser nulo si el autor no lo ha definido.
     */
    @Column(name = "total_chapters")
    private Integer totalChapters;

    /**
     * Estado de la obra en la plataforma de origen (e.g., ONGOING, COMPLETED).
     */
    @Column(name = "publication_status", length = 50)
    private String publicationStatus;

    /**
     * Colección de etiquetas (tags) propias de AO3 (e.g., Fluff, Angst, Slow Burn).
     */
    @OneToMany(mappedBy = "fanfic", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @BatchSize(size = 20)
    private List<FanficTag> tags = new ArrayList<>();

    /**
     * Constructor conveniente para instanciar rápidamente un fanfic usando solo su ID de AO3.
     * @param ao3Id el ID oficial en Archive of Our Own.
     */
    public Fanfiction(String ao3Id) {
        this.ao3Id = ao3Id;
    }
}
