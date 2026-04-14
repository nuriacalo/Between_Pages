package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.user.User;
import com.calonuria.backend.model.catalog.Book;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Entidad que representa el diario de lectura de un libro.
 * Mapea la tabla "book_journal" de la base de datos.
 */
@Entity
@Table(name = "book_journal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BookJournal {

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
     * Libro asociado al diario.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    /**
     * Estado de lectura: PENDING, READING, FINISHED, DROPPED.
     */
    @Column(nullable = false, length = 50)
    private String status;

    /**
     * Página actual de lectura.
     */
    @Column(name = "current_page")
    private Integer currentPage;

    /**
     * Valoración del libro (1-5).
     */
    @Column
    private Integer rating;

    /**
     * Formato de lectura: PHYSICAL, DIGITAL, AUDIOBOOK.
     */
    @Column(name = "reading_format", length = 50)
    private String readingFormat;

    /**
     * Emociones experimentadas durante la lectura (JSON).
     */
    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private List<String> emotions;

    /**
     * Citas favoritas del libro.
     */
    @Column(name = "favorite_quotes", columnDefinition = "TEXT")
    private String favoriteQuotes;

    /**
     * Notas personales del usuario sobre el libro.
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
