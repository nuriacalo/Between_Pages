package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.model.catalog.Manga;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "manga_journal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MangaJournal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_manga_journal")
    private Long idMangaJournal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_manga", nullable = false)
    private Manga manga;

    @Column(nullable = false, length = 50)
    private String estado;

    @Column(name = "capitulo_actual")
    private Integer capituloActual;

    @Column(name = "volumen_actual")
    private Integer volumenActual;

    private Integer valoracion;

    @Column(name = "formato_lectura", length = 50)
    private String formatoLectura;

    @Column(name = "personaje_favorito", length = 150)
    private String personajeFavorito;

    @Column(name = "arco_favorito", length = 150)
    private String arcoFavorito;

    @Column(name = "nota_personal", columnDefinition = "TEXT")
    private String notaPersonal;

    @Column(name = "fecha_inicio")
    private LocalDate fechaInicio;

    @Column(name = "fecha_fin")
    private LocalDate fechaFin;

    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        this.fechaActualizacion = LocalDateTime.now();
    }
}