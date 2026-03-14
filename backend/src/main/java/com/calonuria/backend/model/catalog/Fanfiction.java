package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "fanfiction")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Fanfiction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_fanfic")
    private Long idFanfic;

    @Column(name = "ao3_id", unique = true, length = 50)
    private String ao3Id;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false)
    private String autor;

    @Column(name = "historia_base")
    private String historiaBase;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "portada_url")
    private String portadaUrl;

    @Column(length = 100)
    private String genero;

    @Column(name = "ship_principal", length = 150)
    private String shipPrincipal;

    @Column(length = 150)
    private String tematica;

    @Column(name = "capitulo_actual")
    private Integer capituloActual;

    @Column(name = "total_capitulos")
    private Integer totalCapitulos;

    @Column(name = "estado_publicacion", length = 50)
    private String estadoPublicacion;
}