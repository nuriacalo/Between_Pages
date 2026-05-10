package com.calonuria.backend.features.journal.model;

import com.calonuria.backend.features.catalog.model.Manga;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * Entidad que representa el diario de lectura de un manga.
 * Mapea la tabla "manga_journal" de la base de datos.
 * Extiende de BaseJournal para campos comunes.
 */
@Entity
@Table(name = "manga_journal")
@Data
@EqualsAndHashCode(callSuper = true)
public class MangaJournal extends BaseJournal {

    /**
     * Manga asociado al diario.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id", nullable = false)
    private Manga manga;

    /**
     * Capítulo actual de lectura.
     */
    @Column(name = "current_chapter")
    private Integer currentChapter;

    /**
     * Volumen actual de lectura.
     */
    @Column(name = "current_volume")
    private Integer currentVolume;

    /**
     * Personaje favorito del manga.
     */
    @Column(name = "favorite_character", length = 150)
    private String favoriteCharacter;

    /**
     * Arco favorito del manga.
     */
    @Column(name = "favorite_arc", length = 150)
    private String favoriteArc;

    /**
     * Persona a la que se ha prestado el libro.
     */
    @Column(name = "loaned_to", length = 100)
    private String loanedTo;
}
