package com.calonuria.backend.features.journal.model;

import com.calonuria.backend.features.user.model.User;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Clase base abstracta para entidades de diario de lectura.
 * Contiene los campos comunes compartidos entre libros, mangas y fanfictions.
 * Las subclases deben definir la relación específica con el item (book/manga/fanfic).
 */
@Data
@MappedSuperclass
public abstract class BaseJournal {

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
     * Estado de lectura: WISHLIST, TBR, READING, PAUSED, DROPPED, FINISHED.
     * Eliminados: PENDING (redundante con TBR), BOUGHT (usar ownership).
     */
    @Column(nullable = false, length = 50)
    private String status;

    /**
     * Valoración del item (1-10).
     */
    @Column
    private Integer rating;

    /**
     * Nivel de lágrimas (0-5).
     */
    @Column(name = "tear_drops")
    private Integer tearDrops;

    /**
     * Nivel de picante/flames (0-5).
     */
    @Column(name = "spice_flames")
    private Integer spiceFlames;

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
     * Indica si es una relectura.
     */
    @Column
    private Boolean rereading;

    /**
     * Notas personales del usuario sobre el item.
     */
    @Column(name = "personal_notes", columnDefinition = "TEXT")
    private String personalNotes;

    /**
     * Formato de lectura: PHYSICAL, DIGITAL, AUDIOBOOK.
     */
    @Column(name = "reading_format", length = 50)
    private String readingFormat;

    /**
     * Tipo de propiedad del libro: DIGITAL, PHYSICAL, NONE, BORROWED.
     */
    @Column(length = 20)
    private String ownership;

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
