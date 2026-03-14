package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

@Data
public class FanficJournalRegistroDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long idUsuario;

    @NotNull(message = "El fanfic es obligatorio")
    private Long idFanfic;

    @NotBlank(message = "El estado es obligatorio")
    @Pattern(regexp = "Pendiente|Leyendo|Terminado|Abandonado",
            message = "Estado no válido")
    private String estado;

    @Min(value = 0, message = "El capítulo no puede ser negativo")
    private Integer capituloActual;

    @Min(value = 1, message = "La valoración mínima es 1")
    @Max(value = 5, message = "La valoración máxima es 5")
    private Integer valoracion;

    private String shipPrincipal;
    private String shipsSecundarios;
    private String tematica;

    @Pattern(regexp = "Ninguno|Bajo|Medio|Alto|Extremo",
            message = "Nivel de angst no válido")
    private String nivelAngst;

    private String fidelidadShip;

    @Pattern(regexp = "Canon|AU|Canon-Divergente",
            message = "Canon vs AU no válido")
    private String canonVsAu;

    private Boolean relectura;
    private String notasPersonales;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}