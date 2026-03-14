package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.LibroRespuestaDTO;
import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class LibroJournalRespuestaDTO {
    private Long idLibroJournal;
    private LibroRespuestaDTO libro;
    private String estado;
    private Integer paginaActual;
    private Integer valoracion;
    private String formatoLectura;
    private List<String> emociones;
    private String citasFavoritas;
    private String notaPersonal;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}