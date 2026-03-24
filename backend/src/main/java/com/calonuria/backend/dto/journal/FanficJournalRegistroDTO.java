package com.calonuria.backend.dto.journal;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.time.LocalDate;

@Data
public class FanficJournalRegistroDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long idUsuario;

    private Long idFanfiction;

    // --- Datos del fanfic (Por si es la primera vez que se añade a la app) ---
    private String ao3Id;
    private String titulo;
    private String autor;
    private String historiaBase;
    private String descripcion;
    private String portadaUrl;
    private String genero;
    private String tematica;
    private Integer totalCapitulos;
    private String estadoPublicacion;
    // ------------------------------------------------------------------------

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
    
    @Min(value = 1, message = "El nivel de angst mínimo es 1")
    @Max(value = 5, message = "El nivel de angst máximo es 5")
    private Integer nivelAngst;
    
    @Min(value = 1, message = "La fidelidad del ship mínima es 1")
    @Max(value = 5, message = "La fidelidad del ship máxima es 5")
    private Integer fidelidadShip;
    
    @Pattern(regexp = "Canon|AU|Canon Divergence", message = "Valor no válido")
    private String canonVsAu;
    
    private Boolean relectura;
    private String notasPersonales;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
}