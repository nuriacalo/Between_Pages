package com.calonuria.backend.features.user.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

/**
 * Entidad que representa un día específico en el que el usuario registró actividad de lectura.
 * Mapea a la tabla 'reading_activity' de la base de datos.
 * Sirve como un "Heatmap" (estilo GitHub) para calcular las rachas diarias (streaks) y
 * visualizar los días activos en la semana.
 */
@Data
@Entity
@Table(name = "reading_activity", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "activity_date"})
})
public class ReadingActivity {

    /**
     * Identificador único auto-generado (Primary Key).
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * El usuario que realizó la actividad.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * La fecha exacta (sin hora) en la que ocurrió la actividad.
     * Solo se permite un registro por usuario y día (Unique Constraint).
     */
    @Column(name = "activity_date", nullable = false)
    private LocalDate activityDate;
}
