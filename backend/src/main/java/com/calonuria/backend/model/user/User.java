package com.calonuria.backend.model.user;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * Entidad que representa un usuario de la aplicación.
 * Mapea la tabla "app_user" de la base de datos.
 */
@Entity
@Table(name = "\"user\"")
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
     * Método que se ejecuta antes de persistir el usuario.
     * Establece la fecha de creación automáticamente.
     */
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
