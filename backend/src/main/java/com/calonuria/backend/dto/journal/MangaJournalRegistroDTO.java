package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class MangaJournalRegistroDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long idUsuario;

    private Long idManga;

    // --- Datos del manga (Por si es la primera vez que se añade a la app) ---
    private String mangadexId;
    private String fuente;
    private String titulo;
    private String mangaka;
    private String demografia;
    private String genero;
    private String descripcion;
    private String portadaUrl;
    private Integer totalCapitulos;
    private Integer totalVolumenes;
    private String estadoPublicacion;
    // ------------------------------------------------------------------------

    @NotBlank(message = "El estado es obligatorio")
    @Pattern(regexp = "Pendiente|Leyendo|Terminado|Abandonado",
            message = "Estado no válido")
    private String estado;

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer capituloActual;

    @Min(value = 0, message = "El volumen no puede ser negativo")
    private Integer volumenActual;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 5, message = "La valoración máxima es 5")
    private Integer valoracion;

    @Pattern(regexp = "Fisico|Digital",
            message = "Formato no válido")
    private String formatoLectura;

    private String personajeFavorito;
    private String arcoFavorito;
    private String notaPersonal;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private Boolean relectura;
}
