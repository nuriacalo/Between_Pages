package com.calonuria.backend.features.user.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa la meta anual de lectura de un usuario.
 * Mapea la tabla "reading_goal" de la base de datos PostgreSQL.
 * Define la cantidad objetivo de libros/obras que un usuario desea leer
 * durante un año específico (Similar al Reading Challenge de Goodreads).
 */
@Entity
@Table(name = "reading_goal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReadingGoal {

    /**
     * Identificador único de la meta (Primary Key).
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
     * El año del calendario al que corresponde esta meta (e.g., 2024, 2025).
     * Solo puede haber una meta por usuario y año (Unique Constraint).
     */
    @Column(name = "goal_year", nullable = false)
    private Integer goalYear;

    /**
     * Cantidad objetivo de obras a leer establecidas por el usuario (e.g., 50 libros).
     */
    @Column(name = "target_amount", nullable = false)
    private Integer targetAmount;
}
