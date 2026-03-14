package com.calonuria.backend.dto.journal;

import com.calonuria.backend.dto.catalog.FanfictionRespuestaDTO;
import lombok.Data;
import java.time.LocalDate;

@Data
public class FanficJournalRespuestaDTO {
    private Long idFanficJournal;
    private FanfictionRespuestaDTO fanfic;
    private String estado;
    private Integer capituloActual;
    private Integer valoracion;
    private String shipPrincipal;
    private String shipsSecundarios;
    private String nivelAngst;
    private String canonVsAu;
    private Boolean relectura;
    private String notasPersonales;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}