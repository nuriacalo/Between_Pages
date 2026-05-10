package com.calonuria.backend.features.user.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa la meta anual de lectura de un usuario.
 * Mapea la tabla "reading_goal" de la base de datos.
 */
@Entity
@Table(name = "reading_goal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReadingGoal {

    /**
     * Identificador único de la meta.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario al que pertenece la meta.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Año de la meta.
     */
    @Column(name = "goal_year", nullable = false)
    private Integer goalYear;

    /**
     * Cantidad objetivo de obras a leer.
     */
    @Column(name = "target_amount", nullable = false)
    private Integer targetAmount;
}
