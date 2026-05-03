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
     * Estado de lectura: PENDING, READING, FINISHED, DROPPED, PAUSED, TBR, WISHLIST, BOUGHT.
     */
    @Column(nullable = false, length = 50)
    private String status;

    /**
     * Página actual de lectura.
     */
    @Column(name = "current_page")
    private Integer currentPage;

    /**
     * Valoración del libro (1-10).
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
     * Tipo de propiedad del libro: DIGITAL, PHYSICAL, NONE, BORROWED.
     */
    @Column(length = 20)
    private String ownership;

    /**
     * Nombre de la serie o saga a la que pertenece el libro.
     */
    @Column(name = "series_name", length = 255)
    private String seriesName;

    /**
     * Orden del libro dentro de la serie.
     */
    @Column(name = "series_order")
    private Double seriesOrder;

    /**
     * Persona a la que se ha prestado el libro.
     */
    @Column(name = "loaned_to", length = 100)
    private String loanedTo;

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
