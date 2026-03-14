package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.MangaRespuestaDTO;
import lombok.Data;
import java.time.LocalDate;

@Data
public class MangaJournalRespuestaDTO {
    private Long idMangaJournal;
    private MangaRespuestaDTO manga;
    private String estado;
    private Integer capituloActual;
    private Integer volumenActual;
    private Integer valoracion;
    private String formatoLectura;
    private String personajeFavorito;
    private String arcoFavorito;
    private String notaPersonal;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}