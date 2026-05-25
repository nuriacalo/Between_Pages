package com.calonuria.backend.features.journal.model;

import com.calonuria.backend.features.catalog.model.Fanfiction;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * Entidad que representa el diario de lectura de un fanfiction.
 * Mapea la tabla "fanfic_journal" de la base de datos.
 * Extiende de BaseJournal para campos comunes.
 */
@Entity
@Table(name = "fanfic_journal")
@Data
@EqualsAndHashCode(callSuper = true)
public class FanficJournal extends BaseJournal {

    /**
     * Fanfiction asociado al diario.
     */
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "fanfic_id", nullable = false)
    private Fanfiction fanfic;

    /**
     * Capítulo actual de lectura.
     */
    @Column(name = "current_chapter")
    private Integer currentChapter;

    /**
     * Ship principal del fanfiction.
     */
    @Column(name = "main_ship", length = 150)
    private String mainShip;

    /**
     * Ships secundarios del fanfiction.
     */
    @Column(name = "secondary_ships", length = 255)
    private String secondaryShips;

    /**
     * Temática del fanfiction.
     */
    @Column(length = 150)
    private String theme;

    /**
     * Nivel de angst: NONE, LOW, MEDIUM, HIGH, EXTREME.
     */
    @Column(name = "angst_level", length = 50)
    private String angstLevel;

    /**
     * Fidelidad al ship.
     */
    @Column(name = "ship_loyalty", length = 50)
    private String shipLoyalty;

    /**
     * Tipo de canon: CANON, AU, CANON_DIVERGENT.
     */
    @Column(name = "canon_type", length = 50)
    private String canonType;

    /**
     * Persona a la que se ha prestado el libro.
     */
    @Column(name = "loaned_to", length = 100)
    private String loanedTo;
}