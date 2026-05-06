package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.catalog.Manga;
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
     * Formato de lectura: PHYSICAL, DIGITAL.
     */
    @Column(name = "reading_format", length = 50)
    private String readingFormat;

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
     * Tipo de propiedad: DIGITAL, PHYSICAL, NONE, BORROWED.
     */
    @Column(length = 20)
    private String ownership;

    /**
     * Persona a la que se ha prestado el manga.
     */
    @Column(name = "loaned_to", length = 100)
    private String loanedTo;
}
