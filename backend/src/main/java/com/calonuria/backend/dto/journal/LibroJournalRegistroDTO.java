package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class LibroJournalRegistroDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long idUsuario;

    @NotNull(message = "El libro es obligatorio")
    private Long idLibro;

    @NotBlank(message = "El estado es obligatorio")
    @Pattern(regexp = "Pendiente|Leyendo|Terminado|Abandonado",
            message = "Estado no válido")
    private String estado;

    @Min(value = 0, message = "La página no puede ser negativa")
    private Integer paginaActual;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 5, message = "La valoración máxima es 5")
    private Integer valoracion;

    @Pattern(regexp = "Fisico|Digital|Audiolibro",
            message = "Formato no válido")
    private String formatoLectura;

    private List<String> emociones;
    private String citasFavoritas;
    private String notaPersonal;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}