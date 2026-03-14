package com.calonuria.backend.model.journal;

import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.model.catalog.Libro;
import io.hypersistence.utils.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "libro_journal")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LibroJournal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_libro_journal")
    private Long idLibroJournal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_libro", nullable = false)
    private Libro libro;

    @Column(nullable = false, length = 50)
    private String estado;

    @Column(name = "pagina_actual")
    private Integer paginaActual;

    private Integer valoracion;

    @Column(name = "formato_lectura", length = 50)
    private String formatoLectura;

    @Type(JsonType.class)
    @Column(columnDefinition = "jsonb")
    private List<String> emociones;

    @Column(name = "citas_favoritas", columnDefinition = "TEXT")
    private String citasFavoritas;

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