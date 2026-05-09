package com.calonuria.backend.model.user;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

/**
 * Entidad que representa un día en el que el usuario ha registrado actividad de lectura.
 * Mapea a la tabla 'reading_activity' de la base de datos.
 */
@Data
@Entity
@Table(name = "reading_activity", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "activity_date"})
})
public class ReadingActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "activity_date", nullable = false)
    private LocalDate activityDate;
}