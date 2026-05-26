package com.calonuria.backend.features.user.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.time.LocalDate; // Import added

/**
 * Entidad que representa un usuario de la aplicación.
 * Mapea la tabla "app_user" de la base de datos.
 */
@Entity
@Table(name = "app_user")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    /**
     * Identificador único del usuario.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Nombre del usuario.
     */
    @Column(nullable = false, length = 100)
    private String name;

    /**
     * Correo electrónico del usuario (único).
     */
    @Column(nullable = false, unique = true, length = 150)
    private String email;

    /**
     * Hash de la contraseña del usuario.
     */
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    /**
     * Rol del usuario (USER o ADMIN).
     */
    @Column(nullable = false, length = 20)
    private String role;

    /**
     * Fecha y hora de creación del usuario.
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * Racha de lectura actual del usuario.
     */
    @Column(name = "current_streak", nullable = false)
    private int currentStreak = 0; // Initialize to 0

    /**
     * Última fecha en la que el usuario registró actividad de lectura.
     */
    @Column(name = "last_reading_date")
    private LocalDate lastReadingDate; // Can be null initially

    /**
     * Método que se ejecuta antes de persistir el usuario.
     * Establece la fecha de creación automáticamente.
     */
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
