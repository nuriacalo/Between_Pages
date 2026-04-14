package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.user.User;
import com.calonuria.backend.model.catalog.Manga;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entidad que representa el diario de lectura de un manga.
 * Mapea la tabla "manga_journal" de la base de datos.
 */
@Entity
@Table(name = "manga_journal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MangaJournal {

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
     * Manga asociado al diario.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id", nullable = false)
    private Manga manga;

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
     * Volumen actual de lectura.
     */
    @Column(name = "current_volume")
    private Integer currentVolume;

    /**
     * Valoración del manga (1-5).
     */
    @Column
    private Integer rating;

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
     * Notas personales del usuario sobre el manga.
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
     * Indica si es una relectura.
     */
    @Column
    private Boolean rereading;

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
