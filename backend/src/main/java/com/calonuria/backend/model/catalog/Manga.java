package com.calonuria.backend.model.catalog;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "manga")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Manga {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_manga")
    private Long idManga;

    @Column(name = "mangadex_id", unique = true, length = 50)
    private String mangadexId;

    @Column(length = 50)
    private String fuente;

    @Column(nullable = false)
    private String titulo;

    @Column(nullable = false)
    private String mangaka;

    @Column(length = 50)
    private String demografia;

    @Column(length = 100)
    private String genero;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "portada_url")
    private String portadaUrl;

    @Column(name = "total_capitulos")
    private Integer totalCapitulos;

    @Column(name = "total_volumenes")
    private Integer totalVolumenes;

    @Column(name = "estado_publicacion", length = 50)
    private String estadoPublicacion;
}