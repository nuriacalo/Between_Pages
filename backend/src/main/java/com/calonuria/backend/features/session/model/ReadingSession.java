package com.calonuria.backend.features.session.model;

import com.calonuria.backend.features.user.model.User;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad para sesiones temporizadas de lectura.
 * Registra tiempo y páginas para calcular velocidad promedio por usuario/item.
 */
@Entity
@Table(name = "reading_session")
@Data
@NoArgsConstructor
public class ReadingSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "item_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private ItemType itemType;

    @Column(name = "item_id", nullable = false)
    private Long itemId;

    @Column(name = "duration_seconds", nullable = false)
    private Integer durationSeconds;

    @Column(name = "pages_read", nullable = false)
    private Integer pagesRead;

    @Column(name = "session_date")
    private LocalDateTime sessionDate = LocalDateTime.now();

    public enum ItemType {
        BOOK, MANGA, FANFIC
    }
}
