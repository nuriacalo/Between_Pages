package com.calonuria.backend.features.session.model;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.user.model.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa una sesión de lectura temporizada.
 * Registra el tiempo exacto invertido y la cantidad de páginas/capítulos leídos
 * para poder calcular la velocidad promedio de lectura (PPH - Páginas por Hora)
 * y predecir el tiempo de lectura (ETA) restante.
 */
@Entity
@Table(name = "reading_session")
@Data
@NoArgsConstructor
public class ReadingSession {

    /**
     * Identificador único de la sesión (Primary Key).
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario que realizó la sesión de lectura.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Libro asociado a esta sesión (si aplica).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id")
    private Book book;

    /**
     * Manga asociado a esta sesión (si aplica).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id")
    private Manga manga;

    /**
     * Fanfiction asociado a esta sesión (si aplica).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fanfic_id")
    private Fanfiction fanfic;

    /**
     * Duración total de la sesión de lectura en segundos.
     */
    @Column(name = "duration_seconds", nullable = false)
    private Integer durationSeconds;

    /**
     * Cantidad de páginas, volúmenes o capítulos que se avanzaron durante esta sesión.
     */
    @Column(name = "pages_read", nullable = false)
    private Integer pagesRead;

    /**
     * Fecha y hora en la que se realizó y registró la sesión.
     */
    @Column(name = "session_date")
    private LocalDateTime sessionDate = LocalDateTime.now();

    /**
     * Valida que la sesión referencie a una y solo una obra del catálogo (relación polimórfica).
     * Se ejecuta automáticamente antes de insertar o actualizar la entidad en la base de datos.
     */
    @PrePersist
    @PreUpdate
    private void validatePolymorphism() {
        int count = 0;
        if (book != null) count++;
        if (manga != null) count++;
        if (fanfic != null) count++;
        if (count != 1) {
            throw new IllegalStateException("ReadingSession must reference exactly ONE item (book, manga, or fanfic).");
        }
    }
}
