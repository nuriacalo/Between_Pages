package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa un fanfiction en el catálogo.
 * Mapea la tabla "fanfiction" de la base de datos.
 */
@Entity
@Table(name = "fanfiction")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Fanfiction {

    /**
     * Identificador único del fanfiction.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Identificador del fanfiction en AO3.
     */
    @Column(name = "ao3_id", unique = true, length = 50)
    private String ao3Id;

    /**
     * Título del fanfiction.
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Autor del fanfiction.
     */
    @Column(nullable = false, length = 255)
    private String author;

    /**
     * Material original del que deriva el fanfiction.
     */
    @Column(name = "source_material", length = 255)
    private String sourceMaterial;

    /**
     * Descripción del fanfiction.
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * URL de la portada del fanfiction.
     */
    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    /**
     * Género del fanfiction.
     */
    @Column(length = 100)
    private String genre;

    /**
     * Ship principal del fanfiction.
     */
    @Column(name = "main_ship", length = 150)
    private String mainShip;

    /**
     * Temática del fanfiction.
     */
    @Column(length = 150)
    private String theme;

    /**
     * Capítulo actual de lectura.
     */
    @Column(name = "current_chapter")
    private Integer currentChapter = 0;

    /**
     * Total de capítulos del fanfiction.
     */
    @Column(name = "total_chapters")
    private Integer totalChapters;

    /**
     * Estado de publicación: ONGOING, COMPLETED, ABANDONED.
     */
    @Column(name = "publication_status", length = 50)
    private String publicationStatus;
}