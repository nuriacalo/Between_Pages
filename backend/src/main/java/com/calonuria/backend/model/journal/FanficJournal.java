package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.user.User;
import com.calonuria.backend.model.catalog.Fanfiction;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entidad que representa el diario de lectura de un fanfiction.
 * Mapea la tabla "fanfic_journal" de la base de datos.
 */
@Entity
@Table(name = "fanfic_journal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FanficJournal {

    /**
     * Identificador único del diario.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario propietario del diario.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Fanfiction asociado al diario.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fanfic_id", nullable = false)
    private Fanfiction fanfic;

    /**
     * Estado de lectura: PENDING, READING, FINISHED, DROPPED.
     */
    @Column(nullable = false, length = 50)
    private String status;

    /**
     * Capítulo actual de lectura.
     */
    @Column(name = "current_chapter")
    private Integer currentChapter;

    /**
     * Valoración del fanfiction (1-5).
     */
    @Column
    private Integer rating;

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
     * Indica si es una relectura.
     */
    @Column
    private Boolean rereading;

    /**
     * Notas personales del usuario sobre el fanfiction.
     */
    @Column(name = "personal_notes", columnDefinition = "TEXT")
    private String personalNotes;

    /**
     * Fecha de inicio de lectura.
     */
    @Column(name = "start_date")
    private LocalDate startDate;

    /**
     * Fecha de finalización de lectura.
     */
    @Column(name = "end_date")
    private LocalDate endDate;

    /**
     * Fecha de última actualización del diario.
     */
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * Método que se ejecuta antes de persistir o actualizar.
     * Establece la fecha de actualización automáticamente.
     */
    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}