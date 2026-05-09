package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa una etiqueta de un fanfiction.
 * Mapea la tabla "fanfic_tag" de la base de datos.
 */
@Entity
@Table(name = "fanfic_tag")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FanficTag {

    /**
     * Identificador único de la etiqueta.
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Fanfiction al que pertenece la etiqueta.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fanfic_id", nullable = false)
    private Fanfiction fanfic;

    /**
     * Texto de la etiqueta.
     */
    @Column(nullable = false, length = 100)
    private String tag;
}