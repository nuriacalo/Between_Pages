package com.calonuria.backend.model.catalog;

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
 * Entidad que representa un fanfiction en el catálogo.
 * Mapea la tabla "fanfiction" de la base de datos.
 */
@Entity
@Table(name = "fanfiction")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Fanfiction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "ao3_id", unique = true, length = 50)
    private String ao3Id;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(nullable = false, length = 255)
    private String author;

    @Column(name = "source_material", length = 255)
    private String sourceMaterial;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "cover_url", length = 255)
    private String coverUrl;

    @ManyToMany(fetch = FetchType.LAZY, cascade = { CascadeType.PERSIST, CascadeType.MERGE })
    @JoinTable(name = "fanfiction_genre",
            joinColumns = @JoinColumn(name = "fanfic_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private Set<Genre> genres = new HashSet<>();

    @Column(name = "main_ship", length = 150)
    private String mainShip;

    @Column(length = 150)
    private String theme;

    @Column(name = "current_chapter")
    private Integer currentChapter = 0;

    @Column(name = "total_chapters")
    private Integer totalChapters;

    @Column(name = "publication_status", length = 50)
    private String publicationStatus;

    @OneToMany(mappedBy = "fanfic", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @BatchSize(size = 20)
    private List<FanficTag> tags = new ArrayList<>();
}
