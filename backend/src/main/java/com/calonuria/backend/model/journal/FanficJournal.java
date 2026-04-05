package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.model.catalog.Fanfiction;
import jakarta.persistence.*;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "fanfic_journal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FanficJournal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_fanfic_journal")
    private Long idFanficJournal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_fanfic", nullable = false)
    private Fanfiction fanfic;

    @Column(nullable = false, length = 50)
    private String estado;

    @Column(name = "capitulo_actual")
    private Integer capituloActual;

    private Integer valoracion;

    @Column(name = "ship_principal", length = 150)
    private String shipPrincipal;

    @Column(name = "ships_secundarios", length = 255)
    private String shipsSecundarios;

    @Column(length = 150)
    private String tematica;

    @Column(name = "nivel_angst")
    private Integer nivelAngst;

    @Column(name= "fidelidad_ship")
    @Min(value = 1, message = "La fidelidad del ship mínima es 1")
    @Max(value = 5, message = "La fidelidad del ship máxima es 5")
    private Integer fidelidadShip;

    @Column(name = "canon_vs_au", length = 50)
    private String canonVsAu;

    private Boolean relectura;

    @Column(name = "notas_personales", columnDefinition = "TEXT")
    private String notasPersonales;

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