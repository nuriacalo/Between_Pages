package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class LibroJournalRegistroDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long idUsuario;

    // Se elimina @NotNull para permitir guardar con los datos de Google Books directamente
    private Long idLibro;

    // --- Datos del libro (Por si es la primera vez que se añade a la app) ---
    private String googleBooksId;
    private String titulo;
    private String autor;
    private String isbn;
    private String editorial;
    private String descripcion;
    private String portadaUrl;
    private String genero;
    private String tipoLibro;
    private Integer anioPublicacion;
    // ------------------------------------------------------------------------

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