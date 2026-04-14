package com.calonuria.backend.model.list;

import com.calonuria.backend.model.user.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa una lista de lectura del usuario.
 * Mapea la tabla "list" de la base de datos.
 */
@Entity
@Table(name = "list")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReadingList {

    /**
     * Identificador único de la lista.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario propietario de la lista.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Nombre de la lista.
     */
    @Column(nullable = false, length = 150)
    private String name;

    /**
     * Descripción de la lista.
     */
    @Column(columnDefinition = "TEXT")
    private String description;
}